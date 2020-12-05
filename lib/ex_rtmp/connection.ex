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

  def handle_info({:tcp, from, msg}, %{handshake: %{complete: false}} = state) do
    handshake = Handshake.buffer(state.handshake, msg)
    # state = Map.update(state, :buf, msg, fn x -> x <> msg end)    

    case Handshake.parse(handshake) do
      %Handshake{stage: :c0} = handshake ->
        :ok = Handshake.send_s0(from, handshake)
        :ok = Handshake.send_s1(from, handshake)

        {:noreply, state}

      %Handshake{stage: :c1} = handshake ->
        :ok = Handshake.send_s0(from, handshake)
        :ok = Handshake.send_s1(from, handshake)

        {:noreply, %{state | handshake: handshake}}

      %Handshake{stage: :c2, complete: true} = handshake ->
        :ok = Handshake.send_s2(from, handshake)
        Logger.info("Handshake completed")

        {:noreply, %{state | handshake: nil}}

      _ ->
        Logger.error("Could not parse message: #{inspect(msg)}")
        {:noreply, state}
    end
  end

  def handle_info({:tcp, from, msg}, %{handshake: nil} = state) do
    IO.inspect("[Connection] Message size: #{byte_size(msg)}")
    IO.inspect(chunk = Chunk.decode(msg))

    case chunk do
      %{command: "connect", stream_id: stream_id, length: length, value: value} ->
        # reply with ServerBW, ClientBW and SetPackageSize
        IO.inspect("[connect] value:")
        IO.inspect(value)
        IO.inspect("send acknoledge")
        IO.inspect(Chunk.acknowledge(stream_id, length))
        IO.inspect(:gen_tcp.send(from, Chunk.acknowledge(stream_id, length)))
        IO.inspect(Chunk.result(stream_id))
        IO.inspect(:gen_tcp.send(from, Chunk.result(stream_id)))
	_ -> nil
    end

    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, state) do
    IO.inspect("[Connection] Closed")

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

  Thie function will be called after a connection timeout
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
