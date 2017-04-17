defmodule ReceivePacketsTest do
  use ExUnit.Case
  doctest VideoChat

  test "should send and receive messages" do
    {:ok, socket} = :gen_udp.open(3010)

    # This is not sending to the bucket
    assert :ok = :gen_udp.send(socket, {127,0,0,1}, 3001, "25413Message")

    assert :ok = VideoChat.EncodingBucket.push "25413Message"
    assert((VideoChat.EncodingBucket.get("25413") |> length) == 1)
    assert :ok = VideoChat.EncodingBucket.push "25413Another one"
    assert :ok = VideoChat.EncodingBucket.push "25413And another one"
    assert VideoChat.EncodingBucket.pop("25413") == "Message"
    assert VideoChat.EncodingBucket.pop("25413") != nil
  end

end
