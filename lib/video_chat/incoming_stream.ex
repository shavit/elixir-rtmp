defmodule VideoChat.IncomingStream do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    incoming_port = Application.get_env(:video_chat, :incoming_port)
    IO.puts "---> Listening on port #{incoming_port} for incoming stream"

    {:ok, _socket} = :gen_udp.open(incoming_port, [:binary,
      {:active, true}, {:buffer, 4096}
      ])
  end

  # Incoming streaming data from the webcam.
  def handle_info({:udp, _socket, _ip, _port, data}, state) do
    # IO.inspect "---> Received #{byte_size(data)} bytes from #{_port}"
    :ok = data
      |> parse_message
      |> write_data

    # Write to the bucket
    # VideoChat.EncodingBucket.add data
    # VideoChat.EncodingBucket.push data

    {:noreply, state}
  end

  def handle_info({_, _socket}, state) do
    {:noreply, state}
  end

  defp write_data(message) do
    # File.write("tmp/picture-#{message.channel}.jpg", message.data)
    # File.write("tmp/picture-#{message.channel}.jpg", message.data, [:append])
    File.write("tmp/video-#{message.channel}.mp4", message.data, [:append])
  end

  # Messages should not exceed 4000 bytes
  defp parse_message(message) do
    # channel: 001
    # resolution: 1 | 2 | 3 | 4
    # data: binary
    <<
      channel :: little-unsigned-integer-size(32),
      resolution :: little-unsigned-integer-size(8),
      data :: binary
    >> = message

    IO.inspect "C:#{channel} | R:#{resolution}"

    %{
      channel: channel,
      resolution: resolution,
      data: data
    }
  end
end
