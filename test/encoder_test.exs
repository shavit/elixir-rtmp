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

    assert :ok = VideoChat.Encoding.Encoder.push pid, "254130001Message"
    assert((VideoChat.Encoding.Encoder.get_one(pid, "254130001") |> length) == 1)
    assert :ok = VideoChat.Encoding.Encoder.push pid, "254130001Another one"
    assert :ok = VideoChat.Encoding.Encoder.push pid, "254130001And another one"
    assert VideoChat.Encoding.Encoder.pop(pid, "254130001") == "Message"
    assert VideoChat.Encoding.Encoder.pop(pid, "254130001") != nil
  end

  test "should get sorted messages", %{pid: pid} do
    assert pid != nil

    # IO.inspect VideoChat.Encoding.Encoder.all_sorted(pid, "25413")
  end

end
