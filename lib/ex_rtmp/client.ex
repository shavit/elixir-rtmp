defmodule ExRTMP.Client do
  @moduledoc """
  `ExRTMP.Client` RTMP client

  Responsible for establishing a connection with the server, creating a handshake,
    sending messages to the encoder, and replying to the server.
  """
  use GenServer, restart: :transient
  alias ExRTMP.Chunk
  alias ExRTMP.ControlMessage
  alias ExRTMP.Encoder
  alias ExRTMP.Handshake
  require Logger

  # TODO: Register and supervise

  # TODO: Discover encoder/decoder from the parent

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def init(opts) do
    ip = opts |> Keyword.get(:ip, "127.0.0.1") |> String.to_charlist()
    port = opts |> Keyword.get(:port, "1939") |> String.to_integer()
    opts = [:binary, {:active, true}, {:packet, 0}]
    {:ok, sock} = :gen_tcp.connect(ip, port, opts)
    {:ok, encoder} = GenServer.start_link(Encoder, opts)

    state = %{
      conn: sock,
      encoder: encoder,
      handshake: true,
      buf: ""
    }

    {:ok, state, {:continue, :handshake}}
  end

  @doc """
  new/1 establishes a connection to a remote rtmp server
  """
  def new(args \\ []), do: start_link(args)

  def handle_continue(:handshake, state) do
    Logger.info("Handshake")
    :ok = Handshake.send_c0(state.conn)
    :ok = Handshake.send_c1(state.conn)

    {:noreply, state}
  end

  def handle_call({:control_message, msg, _opts}, _from, state) do
    res = :gen_tcp.send(state.conn, msg)
    {:reply, res, state}
  end

  def handle_info({:tcp, _from, msg}, %{handshake: true} = state) do
    state = Map.update(state, :buf, msg, fn x -> x <> msg end)

    case Handshake.parse(state.buf) do
      {:s0, msg} ->
        {:noreply, %{state | buf: msg}}

      {:s1, time, msg} ->
        :ok = Handshake.send_c2(state.conn, time)
        {:noreply, %{state | buf: msg}}

      {:s2, _msg} ->
        Logger.debug("Handshake completed")
        {:noreply, %{state | buf: <<>>, handshake: false}}

      _ ->
        Logger.error("Could not parse message")
        {:noreply, state}
    end
  end

  def handle_info({:tcp, _from, msg}, %{handshake: false} = state) do
    Logger.info("TCP message: #{inspect(msg)}")
    GenServer.call(state.encoder, {:encode, msg})

    case Chunk.decode(msg) do
      msg ->
        handle_sender_message(msg, state)
        IO.inspect(msg)

      {:ok, {:continue, callback}} ->
        IO.inspect(msg)
        IO.inspect(callback)
    end

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _port}, state) do
    Logger.info("TCP closed")
    Process.exit(self(), :normal)

    {:noreply, Map.delete(state, :conn)}
  end

  def handle_info(msg, state) do
    Logger.error("handle_info/2 not implemented")

    {:noreply, state}
  end

  defp handle_sender_message(%{body: %{type: :client_pinged}} = msg, state) do
    Logger.info("[Client] Client pinged")
    reply_msg = ControlMessage.client_pinged(1, 2)

    IO.inspect(:gen_tcp.send(state.conn, reply_msg))
  end

  defp handle_sender_message(_msg, _state), do: nil
end
