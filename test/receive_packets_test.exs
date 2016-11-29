defmodule ReceivePacketsTest do
  use ExUnit.Case
  doctest VideoChat

  test "should receive messages" do
    {:ok, socket} = :gen_udp.open(3010)

    assert :ok = :gen_udp.send(socket, {127,0,0,1}, 3001, "Message 1")
  end

end
