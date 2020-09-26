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
    Logger.info("[Server] listen on port #{port}")
    {:ok, socket} = :gen_tcp.listen(port, [:binary, {:active, true}, {:buffer, 65536}])

    state = %{
      clients: [],
      port: port,
      conn: socket
    }

    {:ok, state, {:continue, :accept_connections}}
  end

  def handle_continue(:accept_connections, state) do
    # This need to be supervised better
    {:ok, pid} = Connection.start_link(server: self(), socket: state.conn)
    :ok = :gen_tcp.controlling_process(state.conn, pid)

    # case :gen_tcp.accept(state.conn) do
    #   {:error, reason} ->
    #     {:stop, reason, state}

    #   {:ok, _erl_port} ->
    #     Logger.info("[Server] Accepting connections on port #{state.port}")
    #     :gen_tcp.accept(state.conn)
    #     {:noreply, state}
    # end

    {:noreply, state}
  end

  def handle_cast({:register_client, client}, state) do
    Logger.info("[Server] Register client")
    {:noreply, Map.put(state, :clients, [client | state.clients])}
  end

  def handle_cast({:unregister_client, socket}, state) do
    :ok = :gen_tcp.close(socket)
    Logger.debug("[RTMP] Unregister client of #{Enum.count(state.clients)}")
    clients = Enum.filter(state.clients, &(&1 != socket))
    {:noreply, Map.put(state, :clients, clients)}
  end

  def handle_info({:tcp, from, message}, state) do
    Logger.debug("[RTMP] Received #{byte_size(message)} bytes")
    Logger.debug("[RTMP] From: #{inspect(from)}")

    {:noreply, state}
  end

  # def handle_info({:tcp_closed, from}, state) do
  #   Logger.debug("[RTMP] #{from} | Connection closed")

  #   {:noreply, state}
  # end

  def handle_info({_port, {:exit_status, _code}}, state) do
    Logger.info("Exit")
    {:stop, :normal, state}
  end

  def handle_info({:tcp_closed, _port}, state) do
    Logger.info("[Server] TCP closed")
    Process.exit(self(), :normal)

    {:noreply, Map.delete(state, :conn)}
  end

  def terminate(reason, %{clients: clients, conn: conn}) do
    Logger.info("Closing server and #{Enum.count(clients)} connections")
    Enum.each(clients, fn x -> :gen_tcp.close(x) end)
    :ok = :gen_tcp.close(conn)

    reason
  end
end
