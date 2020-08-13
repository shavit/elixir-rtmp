defmodule ExRTMP.Connection do
  @moduledoc """
  `ExRTMP.Connection` RTMP client connection
  """
  use GenServer
  alias ExRTMP.Connection
  alias ExRTMP.Handshake
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    state = %{
      buf: <<>>,
      handshake: false,
      server: Keyword.get(opts, :server),
      socket: Keyword.get(opts, :socket)
    }

    {:ok, state, {:continue, :accept}}
  end

  def handle_continue(:accept, state) do
    :ok = GenServer.cast(self(), {:accept, state.socket})

    {:noreply, state}
  end

  @doc """
  Async calls to accept connections

  """
  def handle_cast({:accept, socket}, state) do
    case :gen_tcp.accept(socket, 120_000) do
      {:ok, client} -> register_client(client, state)
      {:error, :timeout} -> start_another(state)
    end

    {:noreply, state}
  end

  @doc """
  External calls
  """
  def handle_info({:tcp, from, _ip, _port, message}, state) do
    IO.inspect("[Connection] TCP message")
    IO.inspect(from)

    {:noreply, state}
  end

  def handle_info({:tcp, from, msg}, %{handshake: false} = state) do
    state = Map.update(state, :buf, msg, fn x -> x <> msg end)

    case Handshake.parse_server(msg) do
      {0, msg} ->
        Logger.info("C0")
        IO.inspect(msg)
        :ok = Handshake.send_s0(from)

      {n, msg} ->
        Logger.debug("Debug message #{inspect(n)}")
        IO.inspect(msg)
        {:noreply, %{state | buf: msg}}

      _ ->
        Logger.error("Could not parse message")
        IO.inspect(msg)
        {:noreply, state}
    end
  end

  def handle_info({:tcp, from, message}, %{handshake: true} = state) do
    IO.inspect("[Connection] AMF message")
    IO.inspect(byte_size(message))
    IO.inspect(message)
  end

  def handle_info({:tcp_closed, from}, state) do
    IO.inspect("[Connection] Closed")

    GenServer.cast(state.server, {:unregister_client, from})
    GenServer.stop(self(), :normal)

    {:noreply, state}
  end

  @doc """
  Register the client with the server
  """
  def register_client(client, state) do
    IO.inspect("[Connection] Registered")
    IO.inspect(client)

    {:ok, _pid} = Connection.start_link(server: state.server, socket: state.socket)
    :ok = GenServer.cast(state.server, {:register_client, client})
  end

  @doc """
  Starts another client

  Thie function will be called after a connection timeout
  """
  def start_another(state) do
    # Kill it later
    Logger.debug("[Connection] Timeout. Starting another process: #{inspect(state)}")
    {:ok, _pid} = Connection.start_link(server: state.server, socket: state.socket)
    # GenServer.stop(self(), :normal)
    Process.exit(self(), :normal)
  end
end
