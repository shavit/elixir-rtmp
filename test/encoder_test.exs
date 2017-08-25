defmodule EncoderTest do
  use ExUnit.Case
  doctest VideoChat

  test "should start a worker" do
    action = fn(nil) -> :ok end

    assert :ok = VideoChat.Encoding.StreamEncoder.call_action(action)
    assert :name = VideoChat.Encoding.StreamEncoder.call_action((fn(x) -> x end),
      :name)
  end

  test "should send and receive messages" do
    # {:ok, socket} = :gen_udp.open(3010)
    # This is not sending to the bucket
    # assert :ok = :gen_udp.send(socket, {127,0,0,1}, 3001, "000120001Message")

    assert :ok = VideoChat.Encoding.StreamEncoder.push "254130001Message1"
    assert :ok = VideoChat.Encoding.StreamEncoder.push "254130002Message2"
    assert :ok = VideoChat.Encoding.StreamEncoder.push "254130003Message3"
    assert VideoChat.Encoding.StreamEncoder.get_one("254130001") == "Message1"
    assert VideoChat.Encoding.StreamEncoder.pop("25413") == "Message1"
    assert VideoChat.Encoding.StreamEncoder.pop("25413") == "Message2"
    assert VideoChat.Encoding.StreamEncoder.pop("25413") == "Message3"
    assert VideoChat.Encoding.StreamEncoder.pop("25413") == nil
  end

  test "should get sorted messages" do
    # Insert in the wrong order
    assert :ok = VideoChat.Encoding.StreamEncoder.push "254210001Message-1"
    assert :ok = VideoChat.Encoding.StreamEncoder.push "254210003Message-3"
    assert :ok = VideoChat.Encoding.StreamEncoder.push "254210004Message-4"
    assert :ok = VideoChat.Encoding.StreamEncoder.push "254210002Message-2"

    # Get in the right order
    messages = VideoChat.Encoding.StreamEncoder.get_all("25421")
    assert  Enum.at(messages, 0) |> elem(0) == "0001"
    assert  Enum.at(messages, 1) |> elem(0) == "0002"
    assert  Enum.at(messages, 2) |> elem(0) == "0003"
    assert  Enum.at(messages, 3) |> elem(0) == "0004"
  end

end
