%%%-------------------------------------------------------------------
%% @doc Socket GATEWAY Top supervisor
%% @end
%%%-------------------------------------------------------------------

-module(socket_gateway_sup).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
  SupFlags = #{strategy => one_for_one, intensity => 1, period => 5},
  ChildSpecs = [#{id => socket_gateway_server,
    start => {socket_gateway_server, start_link, []},
    restart => permanent,
    shutdown => brutal_kill,
    type => worker,
    modules => [socket_gateway_server]}],
  {ok, {SupFlags, ChildSpecs}}.