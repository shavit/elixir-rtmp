defmodule VideoChat.EncodingBucket do
  # This module store raw video data from the encoder, and helps manage
  #   encoding processes.
  #
  # In development:
  #   Currently this should work with 1 file and 1 version at a time.
  # use GenServer
  use Supervisor

  def start_link do
    # GenServer.start_link(__MODULE__, [], [name: :encoding_bucket])
    Supervisor.start_link(__MODULE__, :ok)
  end

  def add(message) do
    IO.inspect "---> Adding encoded data"
    VideoChat.Encoder.encode(message)

    GenServer.cast(:encoding_bucket, {:add_message, message})
  end

  def get do
    GenServer.call(:encoding_bucket, :get_messages)
  end

  def pop do
    GenServer.call(:encoding_bucket, :pop_message)
  end

  #
  # Server callbacks
  #

  def init(:ok) do
    children = [
      worker(VideoChat.Encoder, [])
    ]

    # {:ok, messages}
    supervise(children, strategy: :one_for_one)
  end

  def handle_cast({:add_message, new_message}, messages) do
    {:noreply, [new_message | messages]}
  end

  def handle_call(:get_messages, _from, messages) do
    {:reply, messages, messages}
  end

  def handle_call(:pop_message, _from, [message | messages]) do
    {:reply, message, messages}
  end

end
