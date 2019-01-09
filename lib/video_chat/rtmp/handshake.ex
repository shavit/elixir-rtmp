defmodule VideoChat.RTMP.Handshake do

  @doc """
  Create a handshake with the RTMP server

  TODO: Write an example here
  """
  def handshake do
    # TODO: Complete the 6 messages
  end

  defp c0, do: <<0x03::size(8)>>

  defp c1 do
    # <<_::bytes-size(1536)>>
    <<_time::bytes-size(4),
      _zero::bytes-size(4),
      _rand::bytes-size(1528)>>
    = <<timestamp, zero, rand>>
  end

  # TODO: Invalid message
  # TODO: Replace the zero with time (receive)
  # Echos c1
  defp c2, do: c1

  defp s0, do: <<0x03::size(8)>>

  defp s1 do
    # <<_::bytes-size(1536)>>
    <<_time::bytes-size(4),
      _zero::bytes-size(4),
      _rand::bytes-size(1528)>>
    = <<timestamp, zero, rand>>
  end

  # TODO: Invalid message
  # TODO: Replace the zero with time
  # Echos s1
  defp s2, do: s1

  def timestamp do
    # 4 = DateTime.utc_now |> DateTime.to_unix |> :binary.encode_unsigned |> byte_size
    <<_time::bits-size(32)>>
      = DateTime.utc_now |> DateTime.to_unix |> :binary.encode_unsigned
  end

  defp zero, do: <<0, 0, 0, 0>>

  def rand do
    fn -> Enum.random('abcdefghijklmnopqrstuvwxyz0123456789') end
    |> Stream.repeatedly
    |> Enum.take(1528)
    |> to_string
  end
end
