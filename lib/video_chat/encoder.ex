defmodule VideoChat.Encoder do
  use GenServer

  def start_link do
    IO.inspect "---> Starting encoder"
    GenServer.start_link(__MODULE__, [], [name: :encoder])
  end

  def init(_state) do
    # Open a port for the external process
    #   wait for stdin.
    port = Port.open({:spawn, "bin/read_udp_in"}, [:binary])
    # Port.connect port, self()

    {:ok, port}
  end

  def encode(data) do
    GenServer.cast(:encoder, {:encode, data})
  end

  defp log_message(port, message) do
    # Write a message
    {{_year,_month,_day},{h,m,s}} = :calendar.local_time
    port |> Port.command("[#{h}:#{m}:#{s}] #{message}\n")
  end

  #
  # Callbacks
  #

  def handle_cast({:encode, data}, port) do
    # Pipe the data to the external process
    log_message(port, "Hello again")

    {:noreply, port}
  end

end
