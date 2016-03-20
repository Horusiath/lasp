-module(ensemble).
-author("Christopher S. Meiklejohn <christopher.meiklejohn@gmail.com>").

-define(LEXER, ensemble_lexer).
-define(PARSER, ensemble_parser).

-include("lasp.hrl").

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

-ifdef(TEST).

%% @doc Ensure we can parse assignments.
assignment_test() ->
    {ok, Tokens, _EndLine} = ?LEXER:string("A <- 1 2 3 4"),
    LexerExpected = [{var,1,'A'},
                     {'<-',1},
                     {integer,1,1},
                     {integer,1,2},
                     {integer,1,3},
                     {integer,1,4}],
    ?assertMatch(LexerExpected, Tokens),
    {ok, ParseTree} = ?PARSER:parse(Tokens),
    ParserExpected = [{update,{var,1,'A'},[{integer,1,1},
                                           {integer,1,2},
                                           {integer,1,3},
                                           {integer,1,4}]}],
    ?assertMatch(ParserExpected, ParseTree).

%% @doc Ensure we can parse print variables.
print_test() ->
    {ok, Tokens, _EndLine} = ?LEXER:string("A"),
    LexerExpected = [{var,1,'A'}],
    ?assertMatch(LexerExpected, Tokens),
    {ok, ParseTree} = ?PARSER:parse(Tokens),
    ParserExpected = [{query,{var,1,'A'}}],
    ?assertMatch(ParserExpected, ParseTree).

% %% @doc Ensure we can parse map operations.
% map_test() ->
%     {ok, Tokens, _EndLine} = ?LEXER:string("A+1"),
%     LexerExpected = [{var,1,'A'},{function,1,'+'},{integer,1,1}],
%     ?assertMatch(LexerExpected, Tokens),
%     {ok, ParseTree} = ?PARSER:parse(Tokens),
%     ParserExpected = [{query,{var,1,'A'}}],
%     ?assertMatch(ParserExpected, ParseTree).

% %% @doc Ensure we can parse over operations.
% over_test() ->
%     {ok, Tokens, _EndLine} = ensemble_lexer:string("+/A"),
%     Expected = {ok,[{function,1,plus},{over,1,over},{variable,1,"A"}],1},
%     ?assertMatch(Expected, Output).

% parse_assignment_test() ->
%     {ok, Tokens, _Endline} = ensemble_lexer:string("A <- 1 2 3 4"),
%     {ok, ParseTree} = ensemble_parser:parse(Tokens),
%     Expected = true,
%     ?assertMatch(Expected, ParseTree).

%% @doc Parse a full program
file_test() ->
    Filename = code:priv_dir(?APP) ++ "/test.ens",
    {ok, Binary} = file:read_file(Filename),
    List = binary_to_list(Binary),
    {ok, Tokens, _EndLine} = ?LEXER:string(List),
    LexerExpected = [{var,1,'A'},
                     {'<-',1},
                     {integer,1,1},
                     {integer,1,2},
                     {integer,1,3},
                     {integer,1,4},
                     {nl,1},
                     {var,2,'A'},
                     {nl,2}],
    ?assertMatch(LexerExpected, Tokens),
    {ok, ParseTree} = ?PARSER:parse(Tokens),
    ParserExpected = [{update,{var,1,'A'},[{integer,1,1},
                                           {integer,1,2},
                                           {integer,1,3},
                                           {integer,1,4}]},{query,{var,2,'A'}}],
    ?assertMatch(ParserExpected, ParseTree).

-endif.