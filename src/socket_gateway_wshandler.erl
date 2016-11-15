-module(socket_gateway_wshandler).

-include("pokemap_request_pb.hrl").

-export([init/3]).
-export([websocket_init/3]).
-export([websocket_terminate/3]).
-export([websocket_handle/3]).
-export([websocket_info/3]).

-record(state, {
}).

init({tcp, http}, _Req, _Opts) ->
  {upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->
  lager:info("[SOCKET GATEWAY] NEW USER CONNECTED ~p", [self()]),

  State = #state{},

  {ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
  lager:log(info, self(), "[SOCKET GATEWAY] USER DISCONNECTED ~p", [self()]),
  ok.

websocket_handle({ping, _}, Req, State) ->
  {reply, pong, Req, State};

websocket_handle({binary, Msg}, Req, State) ->
  Request = pokemap_request_pb:decode_ownrequest(Msg),

  Sequence = Request#ownrequest.sequence_id,

  %%lager:info("[SOCKET GATEWAY] received request ~p", [Request#ownrequest.request_id]),

  process_request(Request#ownrequest.request_id, Request#ownrequest.request_message, Sequence, Req, State);

websocket_handle(_Data, Req, State) ->
  {ok, Req, State}.

websocket_info({send_response, EventData}, Req, State) ->

  lager:info("[SOCKET GATEWAY] sending data to customer ~p", [EventData]),

  {reply, {text, EventData}, Req, State};

websocket_info({terminate, _}, Req, State) ->
  lager:log(info, self(), "[SOCKET GATEWAY] TERMINATING SOCKET ~p", [self()]),

  {shutdown, Req, State};

websocket_info(Info, Req, State) ->
  lager:info("[SOCKET GATEWAY] received unknown data ~p", [Info]),
  {ok, Req, State}.

%%====================================================================
%% INTERNAL
%%====================================================================

string_to_float(N) ->
  case string:to_float(N) of
    {error, no_float} -> list_to_integer(N);
    {F, _Rest} -> F
  end.

get_min_max_lat_lon_for_node() ->
  NodeName = string:sub_string(atom_to_list(node()), 5),

  SobakaIndex = string:chr(NodeName, $@),

  ResultNodeName = string:sub_string(NodeName, 1, SobakaIndex - 1),

  [MinLat, MaxLat, MinLon, MaxLon] = string:tokens(ResultNodeName, "x"),

  {string_to_float(MinLat), string_to_float(MaxLat), string_to_float(MinLon), string_to_float(MaxLon)}.

is_node_serve_lat_lon(Lat, Lon) ->
  {MinLat, MaxLat, MinLon, MaxLon} = get_min_max_lat_lon_for_node(),

  InvalidLatLng = geohelper:invalid_lat(Lat) orelse geohelper:invalid_lng(Lon),

  case InvalidLatLng of
    true -> false;
    false ->
      case Lat >= MinLat andalso Lat =< MaxLat of
        true ->
          case Lon >= MinLon andalso Lon =< MaxLon of
            true ->
              true;
            false ->
              false
          end;
        false ->
          false
      end
  end.

process_request('SEND_POKEMONS', Msg, Sequence, Req, State) ->
  Message = pokemap_request_pb:decode_ownsendpokemonsrequest(Msg),

  Lat = Message#ownsendpokemonsrequest.latitude,
  Lon = Message#ownsendpokemonsrequest.longitude,
  Pokemons = Message#ownsendpokemonsrequest.pokemon,

  case is_node_serve_lat_lon(Lat, Lon) of
    true ->
      Fun = fun(Pokemon) ->
        Lat1 = Pokemon#ownpokemon.lat,
        Lon1 = Pokemon#ownpokemon.lon,

        InvalidLatLon = geohelper:invalid_lat(Lat1) orelse geohelper:invalid_lng(Lon1),

        case InvalidLatLon of
          true ->
            lager:info("Invalid lat lon received"),
            {400, <<"edited">>, State};
          false ->
            case Pokemon#ownpokemon.spawnpointid of
              undefined ->
                lager:info("Invalid spawn id received");
              _ ->
                case is_list(Pokemon#ownpokemon.spawnpointid) of
                  false ->
                    lager:info("Invalid spawn id received");
                  true ->
                    case length(Pokemon#ownpokemon.spawnpointid) > 0 of
                      false ->
                        lager:info("Invalid spawn id received");
                      true ->

                        case Pokemon#ownpokemon.expiretimestampms > 0 of
                          false ->
                            lager:info("Invalid time received");
                          true ->
                            {Mega, Secs, _} = os:timestamp(),
                            Timestamp = Mega * 1000000 + Secs,
                            TimeToExpire = Pokemon#ownpokemon.expiretimestampms / 1000 - Timestamp,
                            case TimeToExpire < 60 * 60 of
                              false ->
                                lager:info("Invalid time received");
                              true ->
                                case Pokemon#ownpokemon.id > 0 of
                                  false ->
                                    lager:info("Invalid time received");
                                  true ->
                                    case is_node_serve_lat_lon(Lat1, Lon1) of
                                      true ->
                                        add_pokemon_to_teles(Pokemon, Lat1, Lon1);
                                      false ->
                                        error
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
            end,

      lists:foreach(Fun, Pokemons),
      {ok, Req, State};
    false ->
      Response = #ownresponse{
        response_id = 'INVALID_LATLON',
        sequence_id = Sequence
      },

      ResponseData = pokemap_request_pb:encode_ownresponse(Response),

      {reply, [{binary, ResponseData}], Req, State}
  end;


process_request('GET_POKEMONS', Msg, Sequence, Req, State) ->
  Message = pokemap_request_pb:decode_owngetpokemonsrequest(Msg),

  Lat = Message#owngetpokemonsrequest.latitude,
  Lon = Message#owngetpokemonsrequest.longitude,
  Radius = Message#owngetpokemonsrequest.radius,

  case Radius > 10000 of
    true ->
      case is_node_serve_lat_lon(Lat, Lon) of
        true ->
          NewRadius = 10000,
          Pokemons = get_pokemons(Lat, Lon, NewRadius),

          FunMap = fun(Pok) ->
            #ownpokemon{
              id = pokemap_request_pb:int_to_enum(ownpokemonid, Pok#ownpokemon.id),
              lat = Pok#ownpokemon.lat,
              lon = Pok#ownpokemon.lon,
              spawnpointid = Pok#ownpokemon.spawnpointid,
              expiretimestampms = Pok#ownpokemon.expiretimestampms
            }
                   end,

          ResultPokemons = lists:map(FunMap, Pokemons),

          ResponseMessage = #owngetpokemonsresponse{
            pokemon = ResultPokemons
          },

          Response = #ownresponse{
            response_id = 'GET_POKEMONS',
            sequence_id = Sequence,
            response_message = pokemap_request_pb:encode_owngetpokemonsresponse(ResponseMessage)
          },

          ResponseData = pokemap_request_pb:encode_ownresponse(Response),

          {reply, [{binary, ResponseData}], Req, State};

        false ->
          Response = #ownresponse{
            response_id = 'INVALID_LATLON',
            sequence_id = Sequence
          },

          ResponseData = pokemap_request_pb:encode_ownresponse(Response),

          {reply, [{binary, ResponseData}], Req, State}
      end;
    false ->
      case is_node_serve_lat_lon(Lat, Lon) of
        true ->
          Pokemons = get_pokemons(Lat, Lon, Radius),

          FunMap = fun(Pok) ->
            #ownpokemon{
              id = pokemap_request_pb:int_to_enum(ownpokemonid, Pok#ownpokemon.id),
              lat = Pok#ownpokemon.lat,
              lon = Pok#ownpokemon.lon,
              spawnpointid = Pok#ownpokemon.spawnpointid,
              expiretimestampms = Pok#ownpokemon.expiretimestampms
            }
                   end,

          ResultPokemons = lists:map(FunMap, Pokemons),

          ResponseMessage = #owngetpokemonsresponse{
            pokemon = ResultPokemons
          },

          Response = #ownresponse{
            response_id = 'GET_POKEMONS',
            sequence_id = Sequence,
            response_message = pokemap_request_pb:encode_owngetpokemonsresponse(ResponseMessage)
          },

          ResponseData = pokemap_request_pb:encode_ownresponse(Response),

          {reply, [{binary, ResponseData}], Req, State};
        false ->
          Response = #ownresponse{
            response_id = 'INVALID_LATLON',
            sequence_id = Sequence
          },

          ResponseData = pokemap_request_pb:encode_ownresponse(Response),

          {reply, [{binary, ResponseData}], Req, State}
      end
  end;

process_request(_, _, _, Req, State) ->
  {ok, Req, State}.

is_pokemon_expired(Pokemon) ->
  {Mega, Secs, _} = os:timestamp(),
  Timestamp = Mega * 1000000 + Secs,

  PokemonExpireTimestamp = Pokemon#ownpokemon.expiretimestampms / 1000,
  Timestamp > PokemonExpireTimestamp.

%% TELES

get_timestamp() ->
  {Mega, Sec, Micro} = os:timestamp(),
  (Mega * 1000000 + Sec) * 1000 + round(Micro / 1000).

get_pokemons(Lat, Lon, Radius) ->
  Point = rstar_geometry:point2d(Lat, Lon, undefined),
  Timestamp = get_timestamp(),

  {ok, Pokemons} = teles_service_server:query_around('POKEMON_SPACE', Point, Radius),

  ExpiredPokemons = [X || X <- Pokemons, is_pokemon_expired(X)],
  NormalPokemons = [X || X <- Pokemons, is_pokemon_expired(X) =/= true],

  DeleteFun = fun(Pok) ->
    remove_pokemon_from_teles(Pok)
              end,

  lists:foreach(DeleteFun, ExpiredPokemons),

  Timestamp1 = get_timestamp(),

  RequestTime = Timestamp1 - Timestamp,

  lager:info("Get pokemons time ~p ms", [RequestTime]),

  NormalPokemons;

get_pokemons(_, _, _) ->
  error.

add_pokemon_to_teles(Pokemon, Lat, Lon) ->
  lager:info("Added: ~p, Lat: ~p, Lon: ~p, Spawn: ~p", [Pokemon#ownpokemon.id, Lat, Lon, Pokemon#ownpokemon.spawnpointid]),

  teles_service_server:add_object('POKEMON_SPACE', Pokemon, undefined),
  teles_service_server:associate('POKEMON_SPACE', Pokemon, Lat, Lon, undefined),
  ok;

add_pokemon_to_teles(_, _, _) ->
  error.

remove_pokemon_from_teles(Pokemon) ->

  teles_service_server:delete('POKEMON_SPACE', Pokemon),

  ok;

remove_pokemon_from_teles(_) ->
  error.

