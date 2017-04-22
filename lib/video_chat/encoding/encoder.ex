defmodule VideoChat.Encoding.Encoder do
  use GenServer

  def start_link(opts \\ []) do
    IO.puts "---> Starting encoder"
    GenServer.start_link(__MODULE__, opts)
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

  def handle_cast({:encode, data}, port) do

    IO.inspect data

    # Pipe the data to the external process
    port |> Port.command(data)

    {:noreply, port}
  end

  def handle_info({_port, {:data, _msg}}, port) do
    {:noreply, port}
  end

end
