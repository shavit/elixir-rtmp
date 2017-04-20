defmodule ReceivePacketsTest do
  use ExUnit.Case
  doctest VideoChat

  test "should send and receive messages" do
    {:ok, socket} = :gen_udp.open(3010)

    # This is not sending to the bucket
    assert :ok = :gen_udp.send(socket, {127,0,0,1}, 3001, "254130001Message")

    assert :ok = VideoChat.EncodingBucket.push "254130001Message"
    assert((VideoChat.EncodingBucket.get("254130001") |> length) == 1)
    assert :ok = VideoChat.EncodingBucket.push "254130001Another one"
    assert :ok = VideoChat.EncodingBucket.push "254130001And another one"
    assert VideoChat.EncodingBucket.pop("254130001") == "Message"
    assert VideoChat.EncodingBucket.pop("254130001") != nil
  end

end
