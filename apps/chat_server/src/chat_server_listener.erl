-module(chat_server_listener).
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-include_lib("stdlib/include/gen_server.hrl").
-include_lib("kernel/include/inet.hrl").
-include_lib("kernel/include/inet_tcp.hrl").
-include_lib("kernel/include/inet_sctp.hrl").
-include_lib("kernel/include/inet.hrl").

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

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

handle_info({tcp, Socket, Data}, State) ->
    Username = binary_to_list(Data),  % Converte il nome utente da binario a stringa
    case is_valid_username(Username) of
        true ->
            {ok, Pid} = chat_server_sup:spawn_user_handler(Username),
            gen_tcp:send(Socket, "Welcome to the chat server!\n"),
            gen_tcp:controlling_process(Socket, Pid),
            {noreply, State};
        false ->
            gen_tcp:send(Socket, "Invalid username. Please try again.\n"),
            gen_tcp:close(Socket),
            {noreply, State}
    end;


terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
