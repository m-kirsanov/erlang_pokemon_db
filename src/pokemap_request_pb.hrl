-ifndef(OWNREQUEST_PB_H).
-define(OWNREQUEST_PB_H, true).
-record(ownrequest, {
    request_id = erlang:error({required, request_id}),
    sequence_id = erlang:error({required, sequence_id}),
    request_message = erlang:error({required, request_message})
}).
-endif.

-ifndef(OWNGETPOKEMONSREQUEST_PB_H).
-define(OWNGETPOKEMONSREQUEST_PB_H, true).
-record(owngetpokemonsrequest, {
    latitude = erlang:error({required, latitude}),
    longitude = erlang:error({required, longitude}),
    radius = erlang:error({required, radius})
}).
-endif.

-ifndef(OWNSENDPOKEMONSREQUEST_PB_H).
-define(OWNSENDPOKEMONSREQUEST_PB_H, true).
-record(ownsendpokemonsrequest, {
    pokemon = [],
    latitude = erlang:error({required, latitude}),
    longitude = erlang:error({required, longitude})
}).
-endif.

-ifndef(OWNPOKEMON_PB_H).
-define(OWNPOKEMON_PB_H, true).
-record(ownpokemon, {
    id,
    expiretimestampms,
    lat,
    lon,
    spawnpointid
}).
-endif.

-ifndef(OWNRESPONSE_PB_H).
-define(OWNRESPONSE_PB_H, true).
-record(ownresponse, {
    response_id = erlang:error({required, response_id}),
    sequence_id = erlang:error({required, sequence_id}),
    response_message
}).
-endif.

-ifndef(OWNGETPOKEMONSRESPONSE_PB_H).
-define(OWNGETPOKEMONSRESPONSE_PB_H, true).
-record(owngetpokemonsresponse, {
    pokemon = []
}).
-endif.

