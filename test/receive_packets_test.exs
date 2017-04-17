defmodule ReceivePacketsTest do
  use ExUnit.Case
  doctest VideoChat

  test "should receive messages" do
    {:ok, _socket} = :gen_udp.open(3010)

    # assert :ok = :gen_udp.send(socket, {127,0,0,1}, 3001, "Message 1")
    # assert :ok = :gen_udp.send(socket, {127,0,0,1}, 3001, "Message 2")
    # assert :ok = :gen_udp.send(socket, {127,0,0,1}, 3001, "Message 3")

    assert :ok = VideoChat.EncodingBucket.push "25413Message"
    assert((VideoChat.EncodingBucket.get("25413") |> length) == 1)
    assert :ok = VideoChat.EncodingBucket.push "25413What"
    assert :ok = VideoChat.EncodingBucket.push "25413Do"
    IO.inspect VideoChat.EncodingBucket.pop("25413")
    # assert VideoChat.EncodingBucket.pop("25413") != nil
  end

end
