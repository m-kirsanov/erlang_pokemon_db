-module(socket_gateway_server).

-author('ruffnecktsk@gmail.com').

-include("pokemap_request_pb.hrl").

-behaviour(gen_server).

-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  code_change/3,
  handle_info/2,
  terminate/2]).

%%% API

start_link() ->
  lager:info("[SOCKET GATEWAY] STARTING...", []),

  teles_service_server:create_space('POKEMON_SPACE'),

  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

ensure_started(Dispatch) ->
  case cowboy:start_http(http, 100, [{ip, {0, 0, 0, 0}}, {port, 8080}], [{env, [{dispatch, Dispatch}]}]) of
    {ok, _} ->
      lager:info("[SOCKET GATEWAY] STARTED", []),
      {ok, Dispatch};
    {error, {already_started, _}} ->
      lager:info("[SOCKET GATEWAY] ALREADY STARTED", []),
      {ok, Dispatch}
  end,

  case cowboy:start_http(httpv6, 100, [{ip, {0, 0, 0, 0, 0, 0, 0, 0}}, {port, 8081}], [{env, [{dispatch, Dispatch}]}]) of
    {ok, _} ->
      lager:info("[SOCKET GATEWAY IPV6] STARTED", []),
      {ok, Dispatch};
    {error, {already_started, _}} ->
      lager:info("[SOCKET GATEWAY IPV6] ALREADY STARTED", []),
      {ok, Dispatch};
  Error ->
lager:info("error ~p", [Error])
  end.

%%%----------------------------------------------------------------------
%%% Callback functions from gen_server
%%%----------------------------------------------------------------------

init([]) ->
  Dispatch = cowboy_router:compile([
    {'_', [
      {"/gate", socket_gateway_wshandler, []}
    ]}
  ]),
  ensure_started(Dispatch),

  timer:send_interval(timer:seconds(60 * 15), self(), clean_chats).

handle_call(_Request, _From, State) ->
  Reply = ok,
  {reply, Reply, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(clean_chats, State) ->
  lager:info("Start chat cleaning"),

  Point = rstar_geometry:point2d(0, 0, undefined),
  {ok, Pokemons} = teles_service_server:query_around('POKEMON_SPACE', Point, 33000000),

  ExpiredPokemons = [X || X <- Pokemons, is_pokemon_expired(X)],

  ExpiredCount = length(ExpiredPokemons),

  DeleteFun = fun(Pok) ->
    remove_pokemon_from_teles(Pok)
              end,

  lists:foreach(DeleteFun, ExpiredPokemons),

  lager:info("End chat cleaning. Removed ~p pokemons",[ExpiredCount]),

  {noreply, State};

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  lager:info("[SOCKET GATEWAY] TERMINATING...", []),
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

is_pokemon_expired(Pokemon) ->
  {Mega, Secs, _} = os:timestamp(),
  Timestamp = Mega * 1000000 + Secs,

  PokemonExpireTimestamp = Pokemon#ownpokemon.expiretimestampms / 1000,
  Timestamp > PokemonExpireTimestamp.

remove_pokemon_from_teles(Pokemon) ->

  teles_service_server:delete('POKEMON_SPACE', Pokemon),

  ok;

remove_pokemon_from_teles(_) ->
  error.
