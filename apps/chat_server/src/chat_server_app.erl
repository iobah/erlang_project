-module(chat_server_app).
-behaviour(application).
-export([start/2, stop/1]).
start(_StartType, _StartArgs) ->
    chat_server_sup:start_link(),
    ok.
stop(_State) ->
    ok.
