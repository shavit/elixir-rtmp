defmodule EncodingUtilTest do
  use ExUnit.Case
  import VideoChat.Encoding.Util

  test "create new encoder" do
    assert %{path: _from, output: _to} = new("from", "to")
    assert %{path: from, output: to, args: []} = new("from", "to")
    assert from == from
    assert to == to
  end

  test "should add options" do
    assert %{path: _path, output: _output, args: args} = new("from", "to")
      |> add_option(["-level", "3.1"])
      |> add_option(["-ac", "2"])

    assert {"-level", _args} = List.pop_at(args, 0)
    assert {"3.1", _args} = List.pop_at(args, 1)
    assert {"-ac", _args} = List.pop_at(args, 2)
    assert {"2", _args} = List.pop_at(args, 3)
  end

  test "should build a string command" do
    {cmd, args} = new("from", "to")
      |> to_command

    assert cmd == "ffmpeg"
    assert "-i from to" == Enum.join(args, " ")
  end
end
