defmodule VideoChat.RTMP do
  use GenServer

  def start_link({_rtmp_port, name} = opts) do
    GenServer.start_link(__MODULE__, opts, name: name)
  end
  def start_link(_opts), do: {:error, nil}

  # TODO: Implement in TCP
  def init({rtmp_port, _name}) do
    {:ok, _socket} = :gen_udp.open(rtmp_port, [:binary,
      {:active, true}, {:buffer, 524288}
      ])
  end
  def init(_opts), do: {:error, :missing_port}

  # TODO: Implement in TCP
  # TODO: Handle multiple clients
  def handle_info({:udp, socket, _ip, _port, data}, state) do
    IO.inspect "[RTMP] #{socket} | Received #{byte_size(data)} bytes"

    {:noreply, state}
  end

  def handle_info({_, _socket}, state) do
    {:noreply, state}
  end

end
