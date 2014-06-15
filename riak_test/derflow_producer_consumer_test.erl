%% @doc Producer/consumer test application.

-module(derflow_producer_consumer_test).
-author("Christopher Meiklejohn <cmeiklejohn@basho.com>").

-export([test/0,
         producer/3,
         consumer/3]).

-ifdef(TEST).

-export([confirm/0]).

-define(HARNESS, (rt_config:get(rt_harness))).

-include_lib("eunit/include/eunit.hrl").

confirm() ->
    [Nodes] = rt:build_clusters([3]),
    lager:info("Nodes: ~p", [Nodes]),
    Node = hd(Nodes),

    lager:info("Remotely loading code on node ~p", [Node]),
    ok = derflow_test_helpers:load(Nodes),
    lager:info("Remote code loading complete."),

    lager:info("Remotely executing the get minimum test."),
    Result = rpc:call(Node, derflow_producer_consumer_test, test, []),
    ?assertEqual([5,6,7,8,9,10,11,12,13,14], Result),
    pass.

-endif.

test() ->
    {ok, S1} = derflow:declare(),
    derflow:thread(derflow_producer_consumer_test, producer,
                   [0, 10, S1]),
    {ok, S2} = derflow:declare(),
    derflow:thread(derflow_producer_consumer_test, consumer,
                   [S1, fun(X) -> X + 5 end, S2]),
    derflow:get_stream(S2).

producer(Init, N, Output) ->
    if
        (N > 0) ->
            timer:sleep(1000),
            {ok, Next} = derflow:bind(Output, Init),
            producer(Init + 1, N-1,  Next);
        true ->
            derflow:bind(Output, nil)
    end.

consumer(S1, F, S2) ->
    case derflow:read(S1) of
        {ok, nil, _} ->
            derflow:bind(S2, nil);
        {ok, Value, Next} ->
            {ok, NextOutput} = derflow:bind(S2, F, Value),
            consumer(Next, F, NextOutput)
    end.