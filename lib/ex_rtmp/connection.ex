defmodule ExRTMP.Connection do
  @moduledoc """
  `ExRTMP.Connection` RTMP server connection for each client
  """
  use GenServer
  alias ExRTMP.Connection
  alias ExRTMP.Chunk
  alias ExRTMP.Handshake
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    state = %{
      buf: <<>>,
      server: Keyword.get(opts, :server),
      socket: Keyword.get(opts, :socket),
      handshake: Handshake.new()
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
      {:ok, client} ->
        register_client(client, state)
        {:noreply, state}

      {:error, :timeout} ->
        start_another(state)
        {:stop, :closed, state}

      {:error, :closed} ->
        Process.exit(self(), :normal)
        {:stop, :closed, state}
    end
  end

  def handle_info({:tcp, _from, msg}, %{handshake: nil} = state) do
    Logger.debug(
      "[Connection] Got chunk. Message size: #{inspect(byte_size(msg))} | #{inspect(Chunk)}"
    )
    {:ok, _basic_header, rest} = Chunk.decode(state.buf <> msg)

    {:noreply, %{state | buf: rest}}
  end
  
  def handle_info({:tcp, from, msg}, %{handshake: handshake} = state) do
    case Handshake.parse_client(from, msg, handshake) do
    {:ok, buf, _handshake} ->
        Logger.info("[connection] handshake completed")
        {:noreply, %{state | buf: buf, handshake: nil}}

      {:empty, _buf, handshake} ->
        {:noreply, %{state | handshake: handshake}}
      
      {:unmatched, buf, handshake} ->
        Logger.error("[connection] Could not parse message: #{inspect(buf)} | stage: #{handshake.stage}")
        {:noreply, %{state | handshake: handshake}}
    end
  end

  def handle_info({:tcp_closed, socket}, state) do
    Logger.info("[Connection] Closed")

    GenServer.cast(state.server, {:unregister_client, socket})
    Process.exit(self(), :normal)

    {:noreply, state}
  end

  @doc """
  Register the client with the server
  """
  def register_client(client, state) do
    {:ok, _pid} = Connection.start_link(server: state.server, socket: state.socket)
    :ok = GenServer.cast(state.server, {:register_client, client})
  end

  @doc """
  Starts another client

  This function will be called after a connection timeout
  """
  def start_another(state) do
    # Kill it later
    Logger.debug("[Connection] Timeout. Starting another process: #{inspect(state)}")
    {:ok, _pid} = Connection.start_link(server: state.server, socket: state.socket)
    Process.exit(self(), :exit)
  end

  def terminate(reason, %{socket: socket}) do
    :ok = :gen_tcp.close(socket)
    reason
  end

end
