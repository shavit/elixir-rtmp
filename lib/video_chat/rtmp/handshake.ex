defmodule VideoChat.RTMP.Handshake do

  @doc """
  Create a handshake with the RTMP server

  TODO: Write an example here
  """
  def handshake do
    # TODO: Complete the 6 messages
  end

  defp c0, do: <<_::bits-size(8)>> = 3

  defp c1 do
    <<_::bytes-size(1536)>>
    = <<_time::bits-size(32),
      _zero::bytes-size(4),
      _rand::bytes-size(1528)>>
    = <<timestamp, zero, rand>>
  end

  defp timestamp do
    # 4 = DateTime.utc_now |> DateTime.to_unix |> :binary.encode_unsigned |> byte_size
    <<_time::bits-size(32)>>
      = DateTime.utc_now |> DateTime.to_unix |> :binary.encode_unsigned
  end

  defp zero, do: <<0, 0, 0, 0>>

  defp rand do
    fn -> Enum.random('abcdefghijklmnopqrstuvwxyz0123456789') end
    |> Stream.repeatedly
    |> Enum.take(1528)
  end
end
