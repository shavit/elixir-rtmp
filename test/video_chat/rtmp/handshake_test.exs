defmodule VideoChat.RTMP.HandshakeTest do
  use ExUnit.Case

  describe "handshake" do
    alias VideoChat.RTMP.Handshake

    setup do
      tcp_opts = [:binary, {:active, false}, {:buffer, 1800}]
      {:ok, socket} = :gen_tcp.listen(3030, tcp_opts)

      on_exit fn ->
        Process.exit socket, :normal
      end

      %{socket: socket}
    end

    test "send_s0/2 sends 1 byte tcp message and returns the same state", %{socket: socket} do
      state = "some state"
      assert "some state" == Handshake.send_s0 socket, state
    end

    test "send_s1/2 sends 1536 bytes", %{socket: socket} do
      state = %{server_timestamp: Handshake.timestamp, time: Handshake.timestamp, rand: Handshake.rand}
      assert new_state = Handshake.send_s1 socket, {state.time, state.rand}, state
      assert new_state.server_timestamp == <<0, 0, 0, 0>>
      assert new_state.time == state.time
      assert new_state.rand == state.rand
    end

    test "send_s2/2 sends 1536 bytes", %{socket: socket} do
      state = %{server_timestamp: Handshake.timestamp, time: Handshake.timestamp, rand: Handshake.rand}
      assert new_state = Handshake.send_s2 socket, state
      assert new_state.server_timestamp == state.server_timestamp
      assert new_state.time == state.time
      assert new_state.rand == state.rand
    end

    test "timestamp/0 creates a 4 byte timestamp" do
      assert <<_timestamp::bytes-size(4)>> = Handshake.timestamp
    end

    test "rand/0 creates a random string of 1528 bytes" do
      assert 1528 == byte_size(Handshake.rand)
    end
  end
end
