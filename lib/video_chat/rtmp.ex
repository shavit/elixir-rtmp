defmodule VideoChat.RTMP do
  @moduledoc """
  RTMP server
  """
  use GenServer

  # TOOD: Create a pool
  @state %{clients: []}

  def start_link({_rtmp_port, name} = opts) do
    GenServer.start_link(__MODULE__, opts, name: name)
  end
  def start_link(_opts), do: {:error, nil}


  def init({rtmp_port, _name}) do
    # TODO: Adjust the buffer
    # tcp_opts = [:binary, {:active, true}, {:buffer, 4096}]
    tcp_opts = [:binary, {:active, true}, {:buffer, 65536}]
    # TODO: For debugging. Remove this.
    # tcp_opts = [:binary, {:active, true}, {:buffer, 16}]

    with {:ok, socket} <- :gen_tcp.listen(rtmp_port, tcp_opts),
      :ok <- GenServer.cast(self(), {:accept, socket}) do
        IO.inspect "[RTMP] Accepting connections on port #{rtmp_port}"

        {:ok, Enum.into(%{port: rtmp_port}, @state)}
    else error ->
      IO.inspect :stderr, error
      error
    end
  end
  def init(_opts), do: {:error, :missing_port}

  alias VideoChat.RTMP.Connection

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
    IO.inspect "[RTMP] Unregister client"
    clients = Enum.filter(state.clients, &(&1 != client))
    {:noreply, Map.put(state, :clients, clients)}
  end

  @doc """
  External calls

  """
  def handle_info({:tcp, from, message}, state) do
    IO.inspect "[RTMP] Received #{byte_size(message)} bytes"
    IO.inspect from

    {:noreply, state}
  end

  def handle_info({:tcp_closed, from}, state) do
    IO.inspect "[RTMP] #{from} | Connection closed"

    {:noreply, state}
  end
end
