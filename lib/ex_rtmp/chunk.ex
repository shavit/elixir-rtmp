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
      <<0::2, 1::6, csid::16, timestamp::3 * 8, size::3 * 8, message_type_id::8, sid::little-size(4)-unit(8), rest::binary>> ->
	Logger.debug "Type 0.1 cs id #{csid} | Chunk message header 0"
      <<0::2, csid::6, 16777215::3 * 8, size::3 * 8, message_type_id::8, sid::little-size(4)-unit(8), timestamp::4 * 8, rest::binary>> ->
	Logger.debug "Type 0.2 cs id #{csid} | Chunk message header 0"
      <<0::size(2), csid::size(6), timestamp::size(24), message_length::size(24), message_type_id::size(8), message_stream_id::little-size(4)-unit(8), rest::binary>> ->
	mtype = Message.get_control_message(message_type_id)
	Logger.debug "Type 0 | cs id #{csid} | #{mtype}"
	decode_message_header(rest)

      <<1::size(2), csid::size(6), _rest::binary>> ->	
	Logger.debug "Type 1"
      <<2::size(2), csid::size(6), _rest::binary>> ->
	Logger.debug "Type 2"
      <<3::size(2), csid::size(6), _rest::binary>> ->
	Logger.debug "Type 3"
	
      <<0::size(2), 0::size(6), 0xFFFFFF::size(24), message_length::size(24),
        message_type_id::size(8), msg_stream_id::size(32), timestamp::size(32), rest::binary>> ->
	Logger.debug("Type 0.1")

      _ ->
	Logger.error("Could not parse chunk")
	{:error, "could not parse meessage"}
    end
  end

  # TODO: This is the body
  defp decode_message_header(header) do
    IO.inspect ">>> header"
    IO.inspect header
    IO.inspect "<<< header"
    # decode command <<0x14>> == <<20>>
    read_object(header)

    header
  end

  # keys are strings, values can be anything
  # <<110, 97, 109, 101, 2, 0, 4, 77, 105, 107, 101, 0, 3, 97, 103, 101, 0, 64, 62>>
  defp read_object(<<2, size::unsigned-size(16), rest::binary>>) do
    IO.inspect ">>> Reading string (usually key) of size #{size}"
    IO.inspect rest
    IO.inspect ">>> kv"
    IO.inspect kv = binary_part(rest, 0, size)
    IO.inspect "<<< kv"
    <<kv::binary-size(size), rest::binary>> = rest
    IO.inspect ">>> rest"
    IO.inspect rest
    IO.inspect "<<< rest"

    read_object(rest)
  end

  defp read_object(<<0, size::unsigned-size(16), rest::binary>>) do
    IO.inspect ">>> read number of size #{size}"
    IO.inspect kv = binary_part(rest, 0, size)
    IO.inspect "<<< read number"
    <<kv::binary-size(size), rest::binary>> = rest
  end
  
  defp read_object(<<type::size(8), size::unsigned-size(16), rest::binary>> = raw) do
    IO.inspect ">>> raw"
    IO.inspect raw
    IO.inspect "<<< raw"    
    IO.inspect ">>> Reading type #{type} #{Message.get_control_message(type)}"
    IO.inspect rest
    IO.inspect ">>> kv size #{size}"
    kv = binary_part(rest, 0, size)
    IO.inspect kv
    IO.inspect "<<< kv"

    kv
  end
  
  defp read_object(rest), do: rest
  
  defp decode_message_header_2(header) do
    case header do	
      <<message_type::size(8), payload_length::unsigned-size(24), timestamp::size(32), sid::little-size(24), payload::binary>> ->
	IO.inspect "message type #{message_type}"
	IO.inspect "payload length #{payload_length}"
	IO.inspect "timestamp #{timestamp}"
	IO.inspect "stream id #{sid}"
	IO.inspect "actual payload size #{byte_size(payload)}"
	IO.inspect payload
	IO.inspect decode_message_payload(payload)

      _ -> {:error, "could not parse message header"}
    end
  end

  def decode_message_payload(payload) do
    # 2 bytes for key/value length    
    # read until 0x0, 0x0, 0x09
    case payload do
      <<_garbage::unit(8)-size(8), amf::binary>> ->
	read_amf(amf, [])
      _ -> {:error, "could not parse message payload"}
    end
  end

  def read_amf(<<0x03, 0x0, msg::binary>>, msg_l) do
    # temporary
    # String.split(msg, <<0x0>>)
    #read_amf(msg, <<>>, msg_l)
  end

  def parse(message) do
    IO.inspect("[Chunk] | parsing #{byte_size(message)} bytes")

    case message do
      # This must be used at the start of a chunk stream
      # Type 0 - 11 bytes
      # If the timestamp is greater than or equal to 0xFFFFFF, the timestamp
      #   field must be 16777215, indicating the presence of the extended
      #    timestamp.
      # Type 0 - 11 bytes
      <<0::size(2), 0::size(6), 0xFFFFFF::size(24), message_length::size(24),
        message_type_id::size(8), msg_stream_id::size(32), timestamp::size(32), rest::binary>> ->
	Logger.debug("Type 0.1")

        create_message_response(%Message{
          message_stream_id: msg_stream_id,
          message_type_id: message_type_id,
          message_control: Message.get_control_message(message_type_id),
          chunk_type: 0,
          length: message_length,
          time: timestamp,
          body: rest
        })

      <<0::size(2), 0::size(6), timestamp::size(24), message_length::size(24),
        message_type_id::size(8), msg_stream_id::size(32), rest::binary>> ->
        Logger.debug("Type 0.2")

        create_message_response(%Message{
          message_stream_id: msg_stream_id,
          message_type_id: message_type_id,
          message_control: Message.get_control_message(message_type_id),
          chunk_type: 0,
          length: message_length,
          time: timestamp,
          body: rest
        })

      # Type 1 - 7 bytes
      <<1::size(2), 0::size(6), 0xFFFFFF::size(24), message_length::size(24),
        message_type_id::size(8), msg_stream_id::size(32), timestamp::size(32), rest::binary>> ->
        Logger.debug("Type 1.1")

        create_message_response(%Message{
          message_stream_id: msg_stream_id,
          message_type_id: message_type_id,
          message_control: Message.get_control_message(message_type_id),
          chunk_type: 1,
          length: message_length,
          time: timestamp,
          body: rest
        })

      <<1::size(2), 0::size(6), timestamp::size(24), message_length::size(24),
        message_type_id::size(8), msg_stream_id::size(32), rest::binary>> ->
        Logger.debug("Type 1.2")

        create_message_response(%Message{
          message_stream_id: msg_stream_id,
          message_type_id: message_type_id,
          message_control: Message.get_control_message(message_type_id),
          chunk_type: 1,
          length: message_length,
          time: timestamp,
          body: rest
        })

      # Type 2 - 3 bytes. Without stream ID or message length.
      <<2::size(2), 0::size(6), 0xFFFFFF::size(24), message_length::size(24),
        message_type_id::size(8), msg_stream_id::size(32), timestamp::size(32), rest::binary>> ->
        Logger.debug("Type 2.1")

        create_message_response(%Message{
          message_stream_id: msg_stream_id,
          message_type_id: message_type_id,
          message_control: Message.get_control_message(message_type_id),
          chunk_type: 2,
          length: message_length,
          time: timestamp,
          body: rest
        })

      <<2::size(2), 0::size(6), timestamp::size(24), message_length::size(24),
        message_type_id::size(8), msg_stream_id::size(32), rest::binary>> ->
        Logger.debug("Type 2.2")

        create_message_response(%Message{
          message_stream_id: msg_stream_id,
          message_type_id: message_type_id,
          message_control: Message.get_control_message(message_type_id),
          chunk_type: 2,
          length: message_length,
          time: timestamp,
          body: rest
        })

      # Type 3 - No message header
      <<3::size(2), 0::size(6), csid::size(8), rest::binary>> ->
        Logger.debug("Type 3.1")

        create_message_response(%Message{
          chunk_stream_id: csid,
          chunk_type: 3,
          body: rest
        })

      <<3::size(2), 0::size(6), csid::size(8), rest::binary>> ->
        Logger.debug("Type 3.2")
        rest

      <<3::size(2), 1::size(6), csid::size(16), rest::binary>> ->
        Logger.debug("Type 3.3")
        rest

      <<3::size(2), csid::size(6), rest::binary>> ->
        Logger.debug("Type 3.3")
        rest

      msg ->
        Logger.debug("Error: Type undefined")
        IO.inspect(msg)
        nil
    end

    message
  end

  defp create_message_response(%Message{} = message) do
    # TODO: In development
    message
  end
end
