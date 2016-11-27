defmodule ReceivePacketsTest do
  use ExUnit.Case
  doctest VideoChat

  test "should receive messages" do
    {:ok, socket} = :gen_udp.open(3010)
    res = :gen_udp.send(socket, {127,0,0,1}, 3001, "Message 1")

    assert res == :ok
  end

  test "should send messages to registry" do
    {:ok, socket} = :gen_udp.open(3010)
    res = :gen_udp.send(socket, {127,0,0,1}, 3001, "Message 2")

    assert res == :ok
  end
end
