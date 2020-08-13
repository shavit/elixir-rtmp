defmodule ExRTMP.Connection do
  @moduledoc """
  `ExRTMP.Connection` RTMP client connection
  """
  use GenServer
  alias ExRTMP.Connection
  alias ExRTMP.Handshake
  require Logger

  @state %{
    server_timestamp: nil,
    time: nil
  }

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    state = %{
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

  def handle_info({:tcp, from, message}, state) do
    case message do
      <<0x03>> ->
        {:noreply, Handshake.send_s0(from, state)}

      <<0x03, time::bytes-size(4), 0, 0, 0, 0, rand::bytes-size(1528)>> ->
        Handshake.send_s0(from, state)
        {:noreply, Handshake.send_s1(from, {time, rand}, state)}

      <<_server_timestamp::bytes-size(4), _time::bytes-size(4), _rand::bytes-size(1528)>> ->
        {:noreply, Handshake.send_s2(from, state)}

      _ ->
        IO.inspect("[Connection] AMF message")
        IO.inspect(byte_size(message))
        IO.inspect(message)

        {:noreply, state}
    end
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
    Logger.debug("[Connection] Timeout. Starting another process: #{inspect(state)}")
    {:ok, _pid} = Connection.start_link(server: state.server, socket: state.socket)
    # GenServer.stop(self(), :normal)
    Process.exit(self(), :normal)
  end
end
