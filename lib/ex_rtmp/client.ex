defmodule ExRTMP.Client do
  @moduledoc """
  `ExRTMP.Client` RTMP client
  """
  use GenServer, restart: :transient
  alias ExRTMP.Chunk
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

    {:ok, %{conn: sock, handshake: true, buf: ""}, {:continue, :handshake}}
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

  def handle_info({:tcp, _from, msg}, %{handshake: true} = state) do
    state = Map.update(state, :buf, msg, fn x -> x <> msg end)

    case Handshake.parse(state.buf) do
      {:s0, msg} ->
        {:noreply, %{state | buf: msg}}

      {:s1, time, msg} ->
        :ok = Handshake.send_c2(state.conn, time)
        {:noreply, %{state | buf: msg}}

      {:s2, msg} ->
        Logger.debug("Handshake completed")
        {:noreply, %{state | buf: <<>>, handshake: false}}

      _ ->
        Logger.error("Could not parse message")
        {:noreply, state}
    end
  end

  def handle_info({:tcp, _from, msg}, %{handshake: false} = state) do
    Logger.info("TCP message")
    IO.inspect msg

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
end
