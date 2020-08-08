defmodule ExRTMP.Handshake do
  @moduledoc """
  Implementation of the RTMP handshake

  http://wwwimages.adobe.com/www.adobe.com/content/dam/acom/en/devnet/rtmp/pdf/rtmp_specification_1.0.pdf

    C0  ----->
    C1  ----->
        <-----  S0
        <-----  S1
    C1  ----->
        <-----  S2
    C2  ----->
  """

  @doc """
  send_c0/2 send the c0 message to the server

    * 1 byte 0x03

  """
  def send_c0(socket) do
    :ok = :gen_tcp.send(socket, <<0x03>>)
  end

  @doc """
  send_c1/2 send the c1 message to the server

    * 1536 octets

  """
  def send_c1(socket) do
    # time 4 bytes +  + 1528 = 1536 octets
    time = <<0, 0, 0, 0>>
    zeros = <<0::4*4>>
    rand = :crypto.strong_rand_bytes(1528)
    :ok = :gen_tcp.send(socket, time <> zeros <> rand)
  end

  @doc """
  Send the s0 message to the client

    * 1 byte 0x03

  Returns an updated state
  """
  def send_s0(socket, state) do
    :ok = :gen_tcp.send(socket, <<0x03>>)

    state
  end

  @doc """
  Send the s1 message

    * 4 bytes time
    * 4 bytes zero
    * 1528 bytes random
  """
  def send_s1(socket, {time, rand}, state) do
    :gen_tcp.send(socket, <<0, 0, 0, 0>> <> <<0, 0, 0, 0>> <> rand)

    state
    |> Map.put(:time, time)
    |> Map.put(:server_timestamp, <<0, 0, 0, 0>>)
    |> Map.put(:rand, rand)
  end

  @doc """
  Send the s2 message
  """
  def send_s2(socket, state) do
    :gen_tcp.send(socket, state.time <> state.server_timestamp <> state.rand)

    state
  end

  def timestamp do
    <<_time::bits-size(32)>> =
      DateTime.utc_now() |> DateTime.to_unix() |> :binary.encode_unsigned()
  end

  defp zero, do: <<0, 0, 0, 0>>

  def rand do
    fn -> Enum.random('abcdefghijklmnopqrstuvwxyz0123456789') end
    |> Stream.repeatedly()
    |> Enum.take(1528)
    |> to_string
  end
end
