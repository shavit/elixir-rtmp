defmodule ExRTMP.Server do
  @moduledoc """
  `ExRTMP.Server` RTMP server
  """
  use GenServer
  alias ExRTMP.Connection
  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    port = Keyword.get(opts, :port, 1935)
    {:ok, socket} = :gen_tcp.listen(port, [:binary, {:active, true}, {:buffer, 65536}])

    state = %{
      clients: [],
      port: port,
      socket: socket
    }

    {:ok, state, {:continue, :accept_connections}}
  end

  def handle_continue(:accept_connections, state) do
    # This need to be supervised better
    {:ok, pid} = Connection.start_link(server: self(), socket: state.socket)
    :ok = :gen_tcp.controlling_process(state.socket, pid)

    Logger.info("[RTMP] Accepting connections on port #{state.port}")
    {:ok, _erl_port} = :gen_tcp.accept(state.socket)

    {:noreply, state}
  end

  # def handle_cast({:register_client, client}, state) do
  #   {:noreply, Map.put(state, :clients, [client | state.clients])}
  # end

  # def handle_cast({:unregister_client, client}, state) do
  #   Logger.debug("[RTMP] Unregister client")
  #   clients = Enum.filter(state.clients, &(&1 != client))
  #   {:noreply, Map.put(state, :clients, clients)}
  # end

  # def handle_info({:tcp, from, message}, state) do
  #   Logger.debug("[RTMP] Received #{byte_size(message)} bytes")
  #   Logger.debug("[RTMP] From: #{inspect(from)}")

  #   {:noreply, state}
  # end

  # def handle_info({:tcp_closed, from}, state) do
  #   Logger.debug("[RTMP] #{from} | Connection closed")

  #   {:noreply, state}
  # end
end
