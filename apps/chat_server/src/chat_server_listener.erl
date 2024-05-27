-module(chat_server_listener).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {
    listen_socket :: any()  % Tipo del campo listen_socket
}).


start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    {ok, LSock} = gen_tcp:listen(1234, [{active, false}, {reuseaddr, true}]),
    {ok, #state{listen_socket=LSock}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({tcp, Socket, Data}, State) ->  % Mancava la specifica dello stato
    {ok, Pid} = chat_server_sup:spawn_user_handler(Data),
    gen_tcp:send(Socket, "Welcome to the chat server!\n"),
    gen_tcp:controlling_process(Socket, Pid),
    {noreply, State};
handle_info({tcp_closed, _Socket}, State) ->  % Mancava la specifica dello stato
    {noreply, State};
handle_info(_Info, State) ->  % Mancava la specifica dello stato
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
