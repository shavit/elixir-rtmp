defmodule ExRTMP.Chunk do
  @moduledoc """

  Chunk format

  Each chunk consists of a 3-part-header and data.

  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  |                     Chunk Header                      |               |
  _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
  |               |                 |                     |               |
  | Basic Header  | Message header  | Extended Timestamp  |  Chunk Data   |
  |               |                 |                     |               |
  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  2 bytes                 - Basic Header: Stream ID, Chunk Type
  0 | 3 | 7 | 11 bytes    - Message Header: Stream ID, Chunk Type
  0 | 4 bytes             - Extended Timestamp
  Variable size           - Chunk Data

    Basic Header

      - - - - - - - - - - - -
      |         FMT         |
      - - - - - - - - - - - -
      |   ID    |   Type    |
      - - - - - - - - - - - -

      Value 0 - 2 bytes
      Value 1 - 3 bytes
      Value 2 - Low level control messages and commands
      Value 3-63 - Stream ID

      Bits 0-5 are the chunk stream ID for values from 2-63
        * 0 indicates  the 2-byte version
        * 1 indicates  the 3-byte version

      * Stream IDs 2-63 can be encoded in the 1-byte form
      * Stream IDs 64-319 can be encoded in the 2-byte form
      * Stream IDs 64-65599 can be encoded in the 3-byte form

    Chunk Message Header

      Contains the message size in bytes, timestamp delta and
        the last 1 byte for the message type.

    There are 4 different formats
      1. Type 0 - 11 bytes
      2. Type 1 - 7 bytes
      3. Type 2 - 3 bytes
      4. Type 3 - No message header


    Type 0, 1 or 2 may have an extended timestamp


    Overall there are 21 header types:
      (3 basic headers) x (2 timestamp type) x (3 chunk message header)
      = 18
      + (1 basic header of value 3) x (3 chunk message header)
      = 21

      + other variations without a header

  Message header fields:

    * message_length - 3 bytes. For type 0 or type 1 chunk
    * message_type_id - 1 byte. For type 0 or type 1
    * message_stream_id - 4 bytes. Message stream ID is stored in little-endian format.

  Protocol Control Messages

    Protocol control messages must have message stream ID 0

    1. Set chunk size
    2. Abort message
    3. Acknowledgment
    5. Window acknowledgment size
  """

  defmodule Message do
    defstruct [
      :message_stream_id,
      :message_type_id,
      :message_control,
      :time,
      :length,
      :chunk_stream_id,
      :chunk_type,
      :header_data,
      :num_bytes_a_header,
      :num_bytes,
      :body
    ]

    @control_messages %{
      0x01 => :set_packet_size,
      0x02 => :abort,
      0x03 => :acknowledge,
      0x04 => :control_message,
      0x05 => :server_bandwidth,
      0x06 => :client_bandwidth,
      0x07 => :virtual_control,
      0x08 => :audio_packet,
      0x09 => :video_packet,
      0x0F => :data_extended,
      0x10 => :container_extended,
      0x11 => :command_extended,
      0x12 => :data,
      0x13 => :container,
      0x14 => :command,
      0x15 => :udp,
      0x16 => :aggregate,
      0x17 => :present
    }

    def get_control_message(message_type_id), do: Map.get(@control_messages, message_type_id)
  end

  require Logger

  def decode(msg) do
    case msg do
      <<0::size(2), 0::size(6), csid::size(8), rest::binary>> ->
	Logger.debug("Type 0 Basic header 1")
	rest

      <<0::size(2), 1::6, csid::16, timestamp::3*8, size::3*8, message_type_id::8,
        sid::little-size(4)-unit(8), rest::binary>> ->
        Logger.debug("Type 0.1 cs id #{csid} | Basic header 2")

      <<0::size(2), csid::6, 16_777_215::size(24), size::size(24), message_type_id::8,
        sid::little-size(4)-unit(8), timestamp::4*8, rest::binary>> ->
        Logger.debug("Type 0.2 cs id #{csid} | Chunk message header 0")

      <<0::size(2), csid::size(6), timestamp::size(24), message_length::size(24),
        message_type_id::size(8), message_stream_id::little-size(4)-unit(8), rest::binary>> ->
        mtype = Message.get_control_message(message_type_id)
        Logger.debug("Type 0 | cs id #{csid} | #{mtype}")
	
        m = %{
	  basic_header: <<0::size(2), csid::size(6)>>,
	  chunk_header: <<timestamp::size(24), message_length::size(24), message_type_id::size(8), message_stream_id::little-size(4)-unit(8)>>,
          type: mtype,
	  message_type_id: message_type_id,
          timestamp: timestamp,
          length: message_length,
          message_stream_id: message_stream_id,
	  size: message_length,
	  rest: rest
        }

        IO.inspect(msg)
	IO.inspect rest
	case  ExRTMP.ControlMessage.decode(rest) do
	  %{timestamp: timestamp, type: :ping_client} ->
	    IO.inspect ">>> reply to ping"
	    IO.inspect ExRTMP.ControlMessage.client_ponged(1, timestamp)
	  _ -> nil
	end

	IO.inspect m

      # TODO: Return this
      # read_chunk(rest, m)

      <<1::size(2), 0::size(6), _rest>> ->
        Logger.debug("Type 1.0")
      <<1::size(2), 1::size(6), _rest>> ->
        Logger.debug("Type 1.1")

      <<1::size(2), csid::size(6), 16_777_215::size(24), _rest::binary>> ->
	Logger.debug("Type 1.3")

      <<1::size(2), csid::size(6), timestamp::size(24), message_length::size(24),
        message_type_id::size(8), message_stream_id::little-size(4)-unit(8), rest::binary>> ->
        Logger.debug("Type 1 <<1::2, csid::6, ...")

	mtype = Message.get_control_message(message_type_id)
        m = %{
	  basic_header: <<1::size(2), csid::size(6)>>,
	  chunk_header: <<timestamp::size(24), message_length::size(24), message_type_id::size(8), message_stream_id::little-size(4)-unit(8)>>,
          type: mtype,
          timestamp: timestamp,
          message_length: message_length,
	  message_type_id: message_type_id,
          message_stream_id: message_stream_id,
	  rest: rest
        }
	IO.inspect m
	IO.inspect msg

	m

      <<2::size(2), 0::size(6), timestamp::size(24), rest::binary>> ->
	Logger.debug("Type 2 <<2, 0, 0, 0, ...")
	
	rest

      <<2::size(2), csid::size(6), _rest::binary>> ->
        Logger.debug("Type 2")

      <<3::size(2), csid::size(6), _rest::binary>> ->
        Logger.debug("Type 3")

      <<0::size(2), 0::size(6), 0xFFFFFF::size(24), message_length::size(24),
        message_type_id::size(8), msg_stream_id::size(32), timestamp::size(32), rest::binary>> ->
        Logger.debug("Type 0.1")

      _ ->
        Logger.error("Could not parse chunk")
        {:error, "could not parse meessage"}
    end
  end

  def read_chunk(<<0x05>>, m), do: m

  def read_chunk(<<0, v::float-64, msg::binary>>, m) do
    m = Map.put(m, :value, v)
    read_chunk(msg, m)
  end

  def read_chunk(<<0x03, _length::size(16), _rest::binary>> = msg, m) do
    <<0x03, msg::binary>> = msg
    msg = read_chunk_object(msg, %{})

    Map.put(m, :body, msg)
  end

  def read_chunk(<<type::size(8), length::size(16), msg::binary>>, m) do
    cmd = binary_part(msg, 0, length)
    m = Map.put(m, :command, cmd)
    <<_value::binary-size(length), msg::binary>> = msg
    read_chunk(msg, m)
  end

  defp read_chunk_object(<<>>, obj), do: Map.delete(obj, nil)

  defp read_chunk_object(msg, obj) do
    {k, msg} = read_chunk_object_key(msg)
    {v, msg} = read_chunk_object_value(msg)

    read_chunk_object(msg, Enum.into(obj, %{k => v}))
  end

  defp read_chunk_object_key(<<0x0, 0x0, 0x09>>), do: {nil, ""}

  defp read_chunk_object_key(<<size::size(16), msg::binary>> = full_message) do
    k = binary_part(msg, 0, size)

    if String.valid?(k) do
      <<_key::binary-size(size), msg::binary>> = msg
      {k, msg}
    else
      {k, n} = read_chunk_object_value_utf8({msg, <<>>, size, 0})
      <<_key::binary-size(n), msg::binary>> = msg
      {k, msg}
    end
  end

  defp read_chunk_object_value(<<0x01, v::unsigned-integer-size(8), msg::binary>>) do
    v = if v == 0, do: false, else: true
    {v, msg}
  end

  defp read_chunk_object_value(<<0x02, size::unsigned-integer-size(16), msg::binary>>) do
    v = binary_part(msg, 0, size)
    <<_value::binary-size(size), msg::binary>> = msg
    {v, msg}
  end

  defp read_chunk_object_value_utf8({<<0x0, _rest::binary>>, acc, _size, n}), do: {acc, n}

  defp read_chunk_object_value_utf8({<<h::utf8, rest::binary>>, acc, size, n}) do
    if bit_size(acc) > size * 8 do
      {acc, n}
    else
      read_chunk_object_value_utf8({rest, acc <> <<h>>, size, n + 1})
    end
  end

  defp read_chunk_object_value_utf8({<<h::size(8), rest::binary>>, acc, size, n}) do
    if bit_size(acc) > size * 8 do
      {acc, n}
    else
      read_chunk_object_value_utf8({rest, acc, size, n + 1})
    end
  end

  defp read_chunk_object_value(<<0, v::float-64, msg::binary>>), do: {v, msg}

  defp read_chunk_object_value(<<>>), do: {nil, <<>>}

  defp read_chunk_object_value(msg) do
    IO.inspect(">>> undefined object value")
    IO.inspect(msg)
    IO.inspect("<<< undefined object value")
    {"undefined", <<>>}
  end

  def acknowledge(stream_id, message_length) do
    # acknowledge
    message_type_id = 0x03
    timestamp = :erlang.timestamp() |> elem(0)
    body = <<0::32>>

    <<0::size(2), stream_id::size(6), timestamp::size(24), message_length::size(24),
      message_type_id::size(8), stream_id::little-size(4)-unit(8), body::binary>>
  end

  def result(stream_id) do
    timestamp = :erlang.timestamp() |> elem(0)
    <<0::size(2), stream_id::size(6), timestamp::size(24)>>
  end
end
