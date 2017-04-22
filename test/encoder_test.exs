defmodule EncoderTest do
  use ExUnit.Case
  doctest VideoChat

  setup do
    {:ok, pid} = VideoChat.Encoding.Encoder.start_link
    [pid: pid]
  end

  test "should start a worker", %{pid: pid} do
    assert pid != nil
    action = fn(nil) -> :ok end

    assert :ok = VideoChat.Encoding.Encoder.call_action(pid, action)
    assert :name = VideoChat.Encoding.Encoder.call_action(pid,
      (fn(x) -> x end),
      :name)
  end

  test "should send and receive messages", %{pid: pid} do
    assert pid != nil
    {:ok, socket} = :gen_udp.open(3010)

    # This is not sending to the bucket
    assert :ok = :gen_udp.send(socket, {127,0,0,1}, 3001, "254130001Message")

    assert :ok = VideoChat.Encoding.Encoder.push pid, "254130001Message1"
    assert :ok = VideoChat.Encoding.Encoder.push pid, "254130002Message2"
    assert :ok = VideoChat.Encoding.Encoder.push pid, "254130003Message3"
    assert VideoChat.Encoding.Encoder.get_one(pid, "254130001") == "Message1"
    assert VideoChat.Encoding.Encoder.pop(pid, "25413") == "Message1"
    assert VideoChat.Encoding.Encoder.pop(pid, "25413") == "Message2"
    assert VideoChat.Encoding.Encoder.pop(pid, "25413") == "Message3"
    assert VideoChat.Encoding.Encoder.pop(pid, "25413") == nil
  end

  test "should get sorted messages", %{pid: pid} do
    assert pid != nil

    assert :ok = VideoChat.Encoding.Encoder.push pid, "254210001Message-1"
    assert :ok = VideoChat.Encoding.Encoder.push pid, "254210003Message-3"
    assert :ok = VideoChat.Encoding.Encoder.push pid, "254210004Message-4"
    assert :ok = VideoChat.Encoding.Encoder.push pid, "254210002Message-2"
    messages = VideoChat.Encoding.Encoder.get_all(pid, "25421")
    assert  Enum.at(messages, 0) |> elem(0) == "0001"
    assert  Enum.at(messages, 1) |> elem(0) == "0002"
    assert  Enum.at(messages, 2) |> elem(0) == "0003"
    assert  Enum.at(messages, 3) |> elem(0) == "0004"
  end

end
