defmodule ReceivePacketsTest do
  use ExUnit.Case
  doctest VideoChat

  test "should receive messages" do
    {:ok, _socket} = :gen_udp.open(3010)

    # assert :ok = :gen_udp.send(socket, {127,0,0,1}, 3001, "Message 1")
    # assert :ok = :gen_udp.send(socket, {127,0,0,1}, 3001, "Message 2")
    # assert :ok = :gen_udp.send(socket, {127,0,0,1}, 3001, "Message 3")

    assert :ok = VideoChat.EncodingBucket.push "25413Message 4"
    IO.inspect VideoChat.EncodingBucket.get "25413"
    # assert((VideoChat.EncodingBucket.get(2441) |> length) > 0)
    # assert VideoChat.EncodingBucket.pop != nil
  end

end
