%%%-------------------------------------------------------------------
%%% @author mihail
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. Апр. 2016 14:42
%%%-------------------------------------------------------------------
-module(teles_service_server).
-author("mihail").

-behaviour(gen_server).
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
  terminate/2, code_change/3]).
-export([get_agent/1, get_agents/1, create_space/1, delete_space/1,
  list_spaces/0, list_objects/1, list_associations/2,
  add_object/3, associate/5, disassociate/3, delete/2,
  query_within/2, query_around/3, query_nearest/3]).

-record(state, {
  num_agents=1, % Number of agents per space
  agents,       % Space -> {[agent()], [agent()], [agent()]}
  pids          % Pid -> {Space, Num}
}).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).
-endif.


start_link(NumAgents) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [NumAgents], []).

%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------

init([NumAgents]) ->
  lager:info("[TELES SERVICE] started by supervisor"),

  State = #state{num_agents=NumAgents, agents=dict:new(), pids=dict:new()},
  {ok, State}.


handle_call({create_space, Space}, _From, State) ->
  {_, State1} = agents_for_space(Space, State),
  {reply, ok, State1};


handle_call({delete_space, Space}, _From, State) ->
  lager:info("Deleting space ~s", [Space]),
  Agents = State#state.agents,
  {Resp, NewState} = case dict:find(Space, Agents) of
                       error -> {not_found, State};
                       {ok, {Pids1, Pids2, Rec}} ->
                         % Instruct all agents to shutdown
                         Pids = lists:append([Pids1, Pids2, Rec]),
                         [gen_server:cast(P, stop) || P <- Pids],

                         % Remove them from the list
                         {ok, State#state{agents=dict:erase(Space, Agents)}}
                     end,
  {reply, Resp, NewState};


handle_call(list_spaces, _From, State) ->
  Agents = State#state.agents,
  Spaces = dict:fetch_keys(Agents),
  {reply, Spaces, State};


handle_call({get_agent, Space}, _From, State) ->
  {Pid, State1} = unshift_agent(Space, State),
  {reply, {ok, Pid}, State1};


handle_call({get_agents, Space}, _From, State) ->
  {{Pid1, Pids2, Rec}, State1} = agents_for_space(Space, State),
  Pids = lists:append([Pid1, Pids2, Rec]),
  {reply, {ok, Pids}, State1}.


% Received when an agent completes recovery
% Adds the agent to the ready list of pids
handle_cast({ready, AgentPid, Space}, State) ->
  % Log the recovery
  lager:info("Agent ~p for ~s recovered!", [AgentPid, Space]),

  Agents = State#state.agents,
  NS = case dict:find(Space, Agents) of
         error -> State;
         {ok, {Pid1, Pid2, Rec}} ->
           Added = {[AgentPid | Pid1], Pid2, Rec -- [AgentPid]},
           NewAgents = dict:store(Space, Added, Agents),
           State#state{agents=NewAgents}
       end,
  {noreply, NS}.


% Update state on an agent being destroyed normally
handle_info({'DOWN', _MonitorRef, _Type, Pid, normal}, State) ->
  Pids = State#state.pids,
  NS = State#state{pids=dict:erase(Pid, Pids)},
  {noreply, NS};


% Handle the shutdown case by ignoring it
handle_info({'DOWN', _MonitorRef, _Type, _Pid, shutdown}, State) ->
  {noreply, State};

% Trigger a repair if we lose an agent
handle_info({'DOWN', _MonitorRef, _Type, Pid, Info}, State) ->
  NS = case dict:find(Pid, State#state.pids) of
         error -> State;
         {ok, {Space, Num}} ->
           % Log death
           lager:error("Data agent ~p for ~p (~p) died with reason ~p",
             [Num, Space, Pid, Info]),

           % Start the replacement agent
           Res = {_, NewPid} = teles_service_sup:start_agent(Num, Space),
           S1 = add_agents(Num, Space, [Res], State),

           % Remove the old AND new pid from the agents
           % The new agent is removed until a recovery can be performed
           {ok, {Pid1, Pid2, Rec}} = dict:find(Space, S1#state.agents),
           SpaceAgents = {Pid1 -- [Pid, NewPid],
               Pid2 -- [Pid, NewPid],
             [NewPid | Rec -- [Pid]]},

           % Notify the new PID to perform a recovery
           gen_server:cast(NewPid, {recover, self(), SpaceAgents}),

           % Return the new state without the new or old pid,
           NewAgents = dict:store(Space, SpaceAgents, State#state.agents),
           #state{agents=NewAgents,
             pids=dict:erase(Pid, S1#state.pids)}
       end,
  {noreply, NS}.


terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.

%% ------------------------------------------------------------------
%% Internal Function Definitions
%% ------------------------------------------------------------------

% Starts new agents for a given space
start_agents(Space, State) ->
  % Log this
  lager:info("Creating space ~s", [Space]),

  % Start the Pids
  Num = State#state.num_agents,
  Pids = teles_service_sup:start_agents(Num, Space),

  % Add the agents and update our state
  add_agents(Num, Space, Pids, State).


% Iteratively processes newly started agents
add_agents(_, _, [], State) -> State;
add_agents(Num, Space, [Res | More], State) ->
  NewState = case Res of
               error ->
                 lager:error("Failed to start data agent num ~d for ~s", [Num, Space]),
                 State;

               {_, Pid} ->
                 % Monitor the process for crashes
                 erlang:monitor(process, Pid),

                 % Map the Pid -> {Space, Num}
                 NewPids = dict:store(Pid, {Space, Num}, State#state.pids),

                 % Map the Space -> {Pid, Pid}
                 Agents = case dict:find(Space, State#state.agents) of
                            error -> {[Pid], [], []};
                            {ok, {Pid1, Pid2, Rec}} -> {[Pid | Pid1], Pid2, Rec}
                          end,
                 NewAgents = dict:store(Space, Agents, State#state.agents),

                 % Update state
                 State#state{agents=NewAgents, pids=NewPids}
             end,
  add_agents(Num - 1, Space, More, NewState).


% Returns a list of pids for a space if they exist,
% or starts them otherwise.
-spec agents_for_space(term(), #state{}) -> {{[pid()], [pid()], [pid()]}, #state{}}.
agents_for_space(Space, State) ->
  Agents = State#state.agents,
  case dict:find(Space, Agents) of
    {ok, Val} -> {Val, State};
    error ->
      S1 = start_agents(Space, State),
      case dict:find(Space, S1#state.agents) of
        {ok, Val} -> {Val, S1};
        error -> {{[], [], []}, S1}
      end
  end.


% Returns the next agent pid, causes a state change.
% This causes requests to load balance across agents.
-spec unshift_agent(term(), #state{}) -> {pid(), #state{}}.
unshift_agent(Space, State) ->
  AgentsDict = State#state.agents,
  {Agents, State1} = agents_for_space(Space, State),
  case Agents of
    % If there is only a single PID, we can save time and
    % avoid the state updates
    {[A], [], _} -> {A, State1};

    % Pop from the left side while we can, append to right
    {[A | More], Other, Recover} ->
      NewAgents = dict:store(Space, {More, [A | Other], Recover}, AgentsDict),
      NewState = State1#state{agents=NewAgents},
      {A, NewState};

    % Reverse right side and move to left
    {[], Ready, Recover} ->
      [A | More] = lists:reverse(Ready),
      NewAgents = dict:store(Space, {More, [A], Recover}, AgentsDict),
      NewState = State1#state{agents=NewAgents},
      {A, NewState}
  end.


% Calls a request to multiple pids
multi_call(Pids, Request, Timeout) ->
  rpc:pmap({gen_server, call}, [Request, Timeout], Pids).


% Checks that all list elements are 'ok'
all_ok([ok | More]) -> all_ok(More);
all_ok([]) -> ok;
all_ok([Val | Other]) -> {error, Val, Other}.


%%%% ------------------------------------------------------------------
%% External Function Definitions
%% ------------------------------------------------------------------

% Gets the Pid of an agent for a space
get_agent(Space) ->
  {ok, Pid} = gen_server:call(?MODULE, {get_agent, Space}),
  Pid.


% Gets all the Pids for agents for a space
get_agents(Space) ->
  {ok, Pids} = gen_server:call(?MODULE, {get_agents, Space}),
  Pids.


% Creates a new space
create_space(Space) ->
  gen_server:call(?MODULE, {create_space, Space}).


% Deletes a space
delete_space(Space) ->
  gen_server:call(?MODULE, {delete_space, Space}).


% Lists the object keys in a given space
list_spaces() ->
  gen_server:call(?MODULE, list_spaces).


% Lists the object keys in a given space
list_objects(Space) ->
  Agent = get_agent(Space),
  gen_server:call(Agent, list_objects).


% Lists associations of an object
list_associations(Space, OID) ->
  Agent = get_agent(Space),
  gen_server:call(Agent, {list_associations, OID}).


% Adds a new object
add_object(Space, OID, Value) ->
  %%lager:info("[TELES SERVICE] adding object ~p with value ~p to space ~p", [OID, Value, Space]),

  Agents = get_agents(Space),
  all_ok(multi_call(Agents, {add_object, OID, Value}, 1000)).


% Adds an association between an object and point
associate(Space, OID, Lat, Lng, Value) ->
  %%lager:info("[TELES SERVICE] associate object ~p with value ~p to lat ~p lon ~p in space ~p", [OID, Value, Lat, Lng, Space]),

  Agents = get_agents(Space),
  all_ok(multi_call(Agents, {associate, OID, Lat, Lng, Value}, 1000)).


% Removes an association between an object and point
disassociate(Space, OID, GID) ->
  Agents = get_agents(Space),
  all_ok(multi_call(Agents, {disassociate, OID, GID}, 1000)).


% Removes an object
delete(Space, OID) ->
  %%lager:info("[TELES SERVICE] delete object ~p in space ~p", [OID, Space]),

  Agents = get_agents(Space),
  all_ok(multi_call(Agents, {delete, OID}, 1000)).


% Queries within a box
query_within(Space, SearchBox) ->
  Agent = get_agent(Space),
  gen_server:call(Agent, {query_within, SearchBox}).


% Search around a point
query_around(Space, SearchPoint, Distance) ->
  Agent = get_agent(Space),
  gen_server:call(Agent, {query_around, SearchPoint, Distance}).


% Search around a point
query_nearest(Space, SearchPoint, K) ->
  Agent = get_agent(Space),
  gen_server:call(Agent, {query_nearest, SearchPoint, K}).

