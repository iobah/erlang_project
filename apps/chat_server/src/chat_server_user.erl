-module(chat_server_user).
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

start_link(Username) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [Username], []).

init([Username]) ->
    {ok, Username}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({tcp, _Socket, Data}, Username) ->
    io:format("[~s]: ~s~n", [Username, Data]),
    {noreply, Username};
handle_info({tcp_closed, _Socket}, Username) ->
    io:format("[~s] disconnected~n", [Username]),
    {stop, normal, Username};
handle_info(_Info, Username) ->
    {noreply, Username}.

terminate(_Reason, _Username) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
