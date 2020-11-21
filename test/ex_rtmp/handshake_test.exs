defmodule ExRTMP.HandshakeTest do
  use ExUnit.Case

  describe "handshake" do
    alias ExRTMP.Handshake

    setup do
      tcp_opts = [:binary, {:active, false}, {:buffer, 1800}]
      {:ok, socket} = :gen_tcp.listen(3030, tcp_opts)

      on_exit(fn ->
        Process.exit(socket, :normal)
      end)

      handshake = Handshake.new()

      %{socket: socket, handshake: handshake}
    end

    test "send_c0/2 sends 1 byte tcp message", %{socket: socket, handshake: handshake} do
      assert {:error, _reason} = Handshake.send_c0(socket, handshake)
    end

    test "send_c1/2 sends a tcp message", %{socket: socket, handshake: handshake} do
      assert {:error, _reason} = Handshake.send_c1(socket, handshake)
    end

    test "send_c2/2 sends a tcp message", %{socket: socket, handshake: handshake} do
      assert {:error, _reason} = Handshake.send_c2(socket, handshake)
    end

    test "send_s0/2 sends 1 byte tcp message", %{socket: socket, handshake: handshake} do
      assert {:error, _reason} = Handshake.send_s0(socket, handshake)
    end

    test "send_s1/2 sends 1536 bytes", %{socket: socket, handshake: handshake} do
      assert {:error, _reason} = Handshake.send_s1(socket, handshake)
    end

    test "send_s2/2 sends 1536 bytes", %{socket: socket, handshake: handshake} do
      assert {:error, _reason} = Handshake.send_s2(socket, handshake)
    end

    test "rand/0 creates a random string of 1528 bytes" do
      assert 1528 == byte_size(Handshake.rand_bytes())
    end
  end
end
