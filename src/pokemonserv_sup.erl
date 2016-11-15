%%%-------------------------------------------------------------------
%% @doc pokemonserv top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(pokemonserv_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->

  protobuffs_compile:generate_source(filename:join([code:priv_dir(pokemonserv), "pokemap_request.proto"])),

  SocketGateway =
    {socket_gateway_sup,
      {socket_gateway_sup, start_link, []},
      permanent,
      5000,
      supervisor,
      [socket_gateway_sup]},

  TelesService = {teles_service,
    {teles_service_sup, start_link, [4]},
    permanent, 60000, supervisor, dynamic},

  {ok, {{one_for_one, 10, 10},
    [
      TelesService,
      SocketGateway
    ]}}.