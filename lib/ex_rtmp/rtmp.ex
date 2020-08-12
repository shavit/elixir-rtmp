defmodule ExRTMP do
  @moduledoc """
  RTMP server
  """
  use GenServer
  alias ExRTMP.Connection
  require Logger

  # TOOD: Create a pool
  @state %{clients: []}

  def start_link({_rtmp_port, name} = opts) do
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def start_link(_opts), do: {:error, nil}

  def init({rtmp_port, _name}) do
    # tcp_opts = [:binary, {:active, true}, {:buffer, 65536}]
    tcp_opts = [:binary, {:active, true}, {:buffer, 100_000}]
    # TODO: For debugging. Remove this.
    # tcp_opts = [:binary, {:active, true}, {:buffer, 16}]

    with {:ok, socket} <- :gen_tcp.listen(rtmp_port, tcp_opts),
         :ok <- GenServer.cast(self(), {:accept, socket}) do
      Logger.info("[RTMP] Accepting connections on port #{rtmp_port}")

      {:ok, Enum.into(%{port: rtmp_port}, @state)}
    else
      error ->
        Logger.error("#{inspect(error)}")
        error
    end
  end

  def init(_opts), do: {:error, :missing_port}

  @doc """
  Async calls to accept connections

  """
  def handle_cast({:accept, socket}, state) do
    {:ok, pid} = Connection.start_link(self(), socket, [])
    :ok = :gen_tcp.controlling_process(socket, pid)
    {:noreply, state}
  end

  def handle_cast({:register_client, client}, state) do
    {:noreply, Map.put(state, :clients, [client | state.clients])}
  end

  def handle_cast({:unregister_client, client}, state) do
    Logger.debug("[RTMP] Unregister client")
    clients = Enum.filter(state.clients, &(&1 != client))
    {:noreply, Map.put(state, :clients, clients)}
  end

  @doc """
  External calls

  """
  def handle_info({:tcp, from, message}, state) do
    Logger.debug("[RTMP] Received #{byte_size(message)} bytes")
    Logger.debug("[RTMP] From: #{inspect(from)}")

    {:noreply, state}
  end

  def handle_info({:tcp_closed, from}, state) do
    Logger.debug("[RTMP] #{from} | Connection closed")

    {:noreply, state}
  end
end
