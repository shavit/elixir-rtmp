defmodule ExRTMP.Handshake do
  @moduledoc """
  Implementation of the RTMP handshake

  The handshake consists of three static-sized chunks rather than variable-sized chunks with headers.
  http://wwwimages.adobe.com/www.adobe.com/content/dam/acom/en/devnet/rtmp/pdf/rtmp_specification_1.0.pdf

    C0  ----->
    C1  ----->
        <-----  S0
        <-----  S1
    C1  ----->
        <-----  S2
    C2  ----->
  """
  defstruct [:stage, :buf, :complete, :time, :client_time]

  def new do
    %__MODULE__{stage: :c0, buf: <<>>, complete: false, time: elem(:erlang.timestamp(), 0)}
  end

  def buffer(%__MODULE__{buf: buf} = handshake, new_buf) do
    %{handshake | buf: buf <> new_buf}
    # Map.update(handshake, :buf, msg, fn x -> x <> msg end)
  end

  @doc """
  send_c0/2 send the c0 message to the server

    * 1 byte 0x03

  """
  def send_c0(socket) do
    :gen_tcp.send(socket, <<0x03>>)
  end

  @doc """
  send_c1/2 send the c1 message to the server

    * 1536 octets

  """
  def send_c1(socket) do
    # time 4 bytes + 4 bytes zeros + 1528 = 1536 octets
    time = :erlang.timestamp() |> elem(0) |> Integer.to_string()
    zeros = <<0::8*4>>
    msg = time <> zeros <> rand()

    :gen_tcp.send(socket, msg)
  end

  @doc """
  send_c2/2 send the c2 message to the server

  It must include the timestamp from s1

  """
  def send_c2(socket, time) do
    time2 = :erlang.timestamp() |> elem(0)
    msg = <<time::size(32), time2::size(32)>> <> rand()
    :gen_tcp.send(socket, msg)
  end

  @doc """
  send_s0/1 Send the s0 message to the client

    * 1 byte 0x03

  Returns an updated state
  """
  def send_s0(socket) do
    :gen_tcp.send(socket, <<0x03>>)
  end

  @doc """
  send_s1/2 Send the s1 message

    * 4 bytes time
    * 4 bytes zero
    * 1528 bytes random
  """
  def send_s1(socket, time) do
    zeros = <<0::8*4>>
    msg = <<time::size(32)>> <> zeros <> rand()

    :gen_tcp.send(socket, msg)
  end

  @doc """
  send_s2/2 Send the s2 message
  """
  def send_s2(socket, time, client_time) do
    msg = <<time::size(32), client_time::size(32)>> <> rand()
    :gen_tcp.send(socket, msg)
  end

  def rand do
    fn -> Enum.random('abcdefghijklmnopqrstuvwxyz0123456789') end
    |> Stream.repeatedly()
    |> Enum.take(1528)
    |> to_string
  end

  def parse(%__MODULE__{buf: msg} = handshake) do
    case msg do
      <<0x03::size(8), rest::binary>> ->
        %{handshake | buf: rest, stage: :c1}

      <<time::unsigned-size(32), 0::unsigned-size(32), _garbage::binary-size(1528)>> ->
        %{handshake | buf: <<>>, stage: :c2}

      <<time::unsigned-size(32), time2::unsigned-size(32), _garbage::binary-size(1528),
        rest::binary>> ->
        %{handshake | buf: <<>>, stage: :c2, complete: true, client_time: time}

      _ ->
        {:invalid, msg}
    end
  end

  def parse(msg) do
    case msg do
      <<0x03::size(8), rest::binary>> ->
        {:s0, rest}

      <<time::size(32), 0::size(32), _garbage::size(1528), rest::binary>> ->
        # Server must wait for C1 before sending S2
        {:s1, time, rest}

      <<_time::size(32), _time2::size(32), _garbage::binary-size(1528), rest::binary>> ->
        # Server must until C2 is received
        {:s2, rest}

      _ ->
        {:invalid, msg}
    end
  end
end
