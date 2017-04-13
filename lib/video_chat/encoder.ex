defmodule VideoChat.Encoder do
  use GenServer

  def start_link do
    IO.puts "---> Starting encoder"
    GenServer.start_link(__MODULE__, [], [name: :encoder])
  end

  def init(_state) do
    # Open a port for the external process
    #   wait for stdin.
    IO.puts "---> Reading webcam bin/read_webcam"
    port = Port.open({:spawn, "bin/read_webcam"}, [:binary])
    # Port.connect port, self()

    {:ok, port}
  end

  def encode(data) do
    GenServer.cast(:encoder, {:encode, data})
  end

  #
  # Callbacks
  #

  def handle_cast({:encode, _data}, port) do

    # Pipe the data to the external process
    # port |> Port.command(data)
    port |> Port.command("Sample data")

    {:noreply, port}
  end

  def handle_info({_port, {:data, _msg}}, port) do
    {:noreply, port}
  end

end
