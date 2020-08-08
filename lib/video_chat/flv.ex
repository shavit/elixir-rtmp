defmodule VideoChat.FLV do
  @moduledoc """
  `FLV` container file format
  """
  defstruct [
    :type,
    :size,
    :stream_id,
    :timestamp_lower,
    :timestamp_upper,
    :payload
  ]

  def type(data) do
    case data do
      <<0x46, 0x4C, 0x56, 0x1, 0x01, length::unsigned-32, _::bits>> -> :video
      # Expanded header
      <<0x46, 0x4C, 0x56, 0x1, 0x01, 0x0, 0x0, 0x0, 0x9, _::bits>> -> :video
      <<0x46, 0x4C, 0x56, 0x1, 0x04, length::unsigned-32, _::bits>> -> :audio
      # Expanded header
      <<0x46, 0x4C, 0x56, 0x1, 0x04, 0x0, 0x0, 0x0, 0x9, _::bits>> -> :audio
      <<0x46, 0x4C, 0x56, 0x1, 0x05, length::unsigned-32, _::bits>> -> :audio_video
      # Expanded header
      <<0x46, 0x4C, 0x56, 0x1, 0x05, 0x0, 0x0, 0x0, 0x9, _::bits>> -> :audio_video
      _ -> :undefined
    end
  end

  # TODO: Remove this
  @doc """
  Parse or decode the stream
  https://en.wikipedia.org/wiki/Flash_Video#Encoding

    * 4 bytes - Size of the previous packet
    * 1 bytes - Packet type: 0x12 (metadata), 0x09 (video), 0x08 (audio)
    * 3 bytes - Payload size
    * 3 bytes - Timestamp lower
    * 1 bytes - Timestamp upper
    * 3 bytes - Stream ID
    * bytes - Payload data

  The first packet is usually a metadata packet
    * 64bit IEEE - "duration"
    * 64bit IEEE - "width", "height"
    * 64bit IEEE - "framerate"
    * Array - "keyframes"
    * Array - "IAdditionalHeader"
      * Array - "Encryption"
      * Base64 encoded string of a signed x.509 certificate - "Metadata"

  Video
  """
  def parse(data) do
    case data do
      # TODO: This is an example
      # TODO: Should return a struct
      <<0x46, 0x4C, 0x56, 0x1, _type::bytes-size(1), _length::bytes-size(4),
        previous_size::unsigned-32, packet_type::bytes-size(1), payload_size::unsigned-24,
        timestamp_lower::unsigned-24, timestamp_upper::bytes-size(1), stream_id::unsigned-24,
        payload_data::bits>> ->
        payload_data

      _ ->
        nil
    end
  end
end
