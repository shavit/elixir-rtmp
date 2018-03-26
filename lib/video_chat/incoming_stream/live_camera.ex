defmodule VideoChat.IncomingStream.LiveCamera do

  def do_stream_live(:init, state) do
    IO.inspect "Init live stream"
    {:ok, state}
  end

  def do_stream_live(:terminate, _state), do: :ok

  def do_stream_live("topic:" <> letter, state, data) do
    {:reply, {:text, %{}}, state}
  end

  def do_stream_live(topic, state, data) do
    {:reply, {:text, %{}}, state}
  end
end
