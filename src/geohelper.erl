%%%-------------------------------------------------------------------
%%% @author mihail
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. Апр. 2016 16:46
%%%-------------------------------------------------------------------
-module(geohelper).
-author("mihail").

-include("pokemap_request_pb.hrl").

%% API
-export([invalid_lat/1,
  invalid_lng/1,
  fill_pokemons/1]).

is_numberr(Num) ->
  case is_float(Num) of
    true ->
      true;
    false ->
      case is_integer(Num) of
        true ->
          true;
        false ->
          false
      end
  end.

% Checks if a latitude is invalid
invalid_lat(Lat) ->
  IsNumber = is_numberr(Lat),

  if
    not IsNumber -> true;
    Lat < -90 orelse Lat > 90 -> true;
    true -> false
  end.


% Checks if a longitude is invalid
invalid_lng(Lng) ->
  IsNumber = is_numberr(Lng),

  if
    not IsNumber -> true;
    Lng < -180 orelse Lng > 180 -> true;
    true -> false
  end.

generate_location(Radius, OriginalLocation) -> %% lat lon
  NewRadius = Radius/111300,
  {Y0, X0} = OriginalLocation,
  Random1 = random:uniform(),
  Random2 = random:uniform(),
  W = NewRadius * math:sqrt(Random1),
  T = 2 * math:pi() * Random2,
  X = W * math:cos(T),
  Y1 = W * math:sin(T),
  X1 = X / math:cos(Y0),
  NewY = Y0 + Y1,
  NewX = X0 + X1,
  {NewY, NewX}.

fill_pokemons(N) when N == 0 ->
  ok;

fill_pokemons(N) when N > 0  ->
  RandomCoordinate = generate_location(10000, {45.045665, 38.979872}),
  {Lat, Lon} = RandomCoordinate,

  {Mega, Secs, _} = os:timestamp(),
  Timestamp = Mega* 1000000 + Secs,

  Pokemon = #ownpokemon {
    id = random:uniform(150) + 1,
    lat = Lat,
    lon = Lon,
    spawnpointid = uuid_md5_helper:generate_uuid(),
    expiretimestampms = (Timestamp * 1000) + (random:uniform(60 * 15 * 1000) + (60 * 60 * 1000))
  },

  teles_service_server:add_object('POKEMON_SPACE', Pokemon, undefined),
  teles_service_server:associate('POKEMON_SPACE', Pokemon, Lat, Lon, undefined),

  fill_pokemons(N-1).