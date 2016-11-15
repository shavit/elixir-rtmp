defmodule VideoChat.IncomingStream do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    IO.puts "---> Listening on port #{3001} for incoming stream"
    {:ok, _socket} = :gen_udp.open(3001, [:binary, {:active, true}])
  end

  # Handle data
  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    # message = packet(data)
    # IO.inspect message
    IO.inspect data

    {:noreply, state}
  end

  # Handle data
  def handle_info({_, _socket}, state) do
    {:noreply, state}
  end

  # Parse packet
  def packet(data) do
    IO.puts "---> Parsing data"
    IO.inspect data

    # 30 bytes * 8 = 240 bits
    <<
      _header :: size(240),
      priority_code :: bitstring-size(8),
      agent_number :: little-unsigned-integer-size(32),
      message :: bitstring-size(320)
    >> = data

    # The message
    %{
      priority_code: priority_code,
      agent_number: agent_number,
      message: String.rstrip(message),
    }
  end
end
