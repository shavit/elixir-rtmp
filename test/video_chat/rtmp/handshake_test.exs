defmodule VideoChat.RTMP.HandshakeTest do
  use ExUnit.Case

  describe "handshake" do
    alias VideoChat.RTMP.Handshake

    test "timestamp/0 creates a 4 byte timestamp" do
      assert <<_timestamp::bytes-size(4)>> = Handshake.timestamp
    end

    test "rand/0 creates a random string of 1528 bytes" do
      assert 1528 == byte_size(Handshake.rand)
    end
  end
end
