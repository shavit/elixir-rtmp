defmodule VideoChat.EncodingBucket do
  # This module store raw video data from the encoder, and helps manage
  #   encoding processes.
  #
  # In development:
  #   Currently this should work with 1 file and 1 version at a time.
  use GenServer

  def start_link do
    {{_year,_month,_day},{h,m,s}} = :calendar.local_time
    System.cmd("sh", ["bin/read_string", "[#{h}:#{m}:#{s}] Started from Eixir"])

    GenServer.start_link(__MODULE__, [], [name: :encoding_bucket])
  end

  def add(message) do
    # IO.inspect "---> Add data"
    # {_stdout, 0} = System.cmd("sh", [
    #     Path.join([System.cwd, "bin", "read_udp_in"]),
    #     message
    #   ], into: IO.stream(:stdio, :line))
    # IO.inspect _stdout

    IO.write(__MODULE__, "foo")

    # {_stdout, 0} = System.cmd("sh", [
    #     Path.join([System.cwd, "bin", "read_string"]),
    #     "message"
    #   ], into: IO.stream(:stdio, :line))
    # IO.inspect _stdout

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

  def init(messages) do
    {:ok, messages}
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
