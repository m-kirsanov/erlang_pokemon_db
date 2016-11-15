%%%-------------------------------------------------------------------
%%% @author ruffneck
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. ноя 2015 15:31
%%%-------------------------------------------------------------------
-module(uuid_md5_helper).
-author("ruffneck").

%% API
-export([generate_md5_hash/1, generate_pass_hash/1, generate_uuid/0, generate_uuid/1]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  MD5 HASH
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

generate_md5_hash(Bin) when is_binary(Bin) ->
  String = binary_to_list(Bin),

  MD5Hex = string:to_upper(
    lists:flatten([io_lib:format("~2.16.0b", [N]) || <<N>> <= erlang:md5(String)])
  ),
  BinaryToken = list_to_binary(MD5Hex),
  BinaryToken.

generate_pass_hash(Bin) when is_binary(Bin) ->
  Salt = get_hash_salt(),
  SaltedBin = <<Bin/binary, Salt/binary>>,
  String = binary_to_list(SaltedBin),
  MD5Hex = string:to_upper(
    lists:flatten([io_lib:format("~2.16.0b", [N]) || <<N>> <= erlang:md5(String)])
  ),
  BinaryToken = list_to_binary(MD5Hex),
  BinaryToken.

get_hash_salt() ->
  <<"blabla90salt">>.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  API TOKEN HELPERS
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-spec generate_uuid() -> BinaryUUID :: binary().
generate_uuid() ->
  UUID = uuid:to_string(uuid:uuid1()),
  BinaryUUID = list_to_binary(UUID),
  BinaryUUID.

-spec generate_uuid(Bin :: binary()) -> BinaryUUID :: binary().
generate_uuid(Bin) ->
  String = binary_to_list(Bin),
  UUID = uuid:to_string(uuid:uuid3(uuid:uuid4(), String)),
  BinaryUUID = list_to_binary(UUID),
  BinaryUUID.