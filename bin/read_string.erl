-module(read_string).
-export([read_string/0]).

read_string() ->
  case io:get_chars('', 3004) of
    eof -> init:stop();
    InputString ->
      Rotated = [read_string(C) || C <- InputString],
      io:put_chars(Rotated),
      read_string()
end.

read_string(C) when C >= $a, C =< $z -> $a + (C - $a + 13) rem 26;
read_string(C) when C >= $A, C =< $Z -> $A + (C - $A + 13) rem 26;
read_string(C) -> C.

% Run
% cat ~/.bashrc | erl -noshell -s read_string read_string | wc
