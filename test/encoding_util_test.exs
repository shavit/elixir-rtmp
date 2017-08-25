defmodule EncodingUtilTest do
  use ExUnit.Case
  import VideoChat.Encoding.Util

  test "create new encoder" do
    assert %{path: from, output: to} = new("from", "to")
    assert from == from
    assert to == to
  end

  test "should add options" do
    assert %{path: _path, output: _output, args: args} = new("from", "to")
      |> add_option(["-level 3.1"])
      |> add_option(["-ac 2"])

    assert {"-level 3.1", _args} = List.pop_at(args, 0)
    assert {"-ac 2", _args} = List.pop_at(args, 1)
  end

  test "should build a string command" do
    {cmd, args} = new("from", "to")
      |> add_option(["-level 3.1"])
      |> add_option(["-ac 2"])
      |> to_command

    assert cmd == "ffmpeg"
    assert "-i from -level 3.1 -ac 2 -o to" == Enum.join(args, " ")
  end
end
