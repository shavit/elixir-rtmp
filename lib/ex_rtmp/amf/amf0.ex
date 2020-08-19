defmodule ExRTMP.AMF.AMF0 do
  @moduledoc """
  `ExRTMP.AMF.AMF0` AMF0 reader and writer

  Command messages have message type value of 20 for AMF0, and 17 for AMF3.
    Each command consists of a name, transaction ID and object

  https://www.adobe.com/content/dam/acom/en/devnet/pdf/amf0-file-format-specification.pdf
  https://en.wikipedia.org/wiki/Action_Message_Format

  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  | 16 bits | 16 bits       | header count*56 | 16 bits       | message count*64 |
  |         |               | + bits          |               | +bits            |
  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  |         |               |                 |               |                  |
  | Version | Header Count  | Header Type     | Message Count | Message Type     |
  |         |               |                 |               |                  |
  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  AMF packet
  16 bits                       - version. Default: 0 or 3
  16 bits                       - header count. Default: 0
  header count * 56 + bits      - header type structure
  16 bits                       - message count. Default 1
  message count * 64 + bits     - message type structure

  Header Type
  16 bits                       - header name length. Default 0
  header-name-length * 8 bits   - header name string
  8 bits                        - must understand
  32 bits                       - header length
  header-length * 8 bits        - amf0 or amf3

  Message type structure
  16 bits                       - target uri length
  target-uri-length * 8 bits    - target-uri-string
  16 bits                       - response uri length
  response-uri-length * 8 bits  - response uri string
  32 bits                       - message length
  message-length * 8 bits       - amf0 or amf3
  """
  @type data_type ::
          :number
          | :boolean
          | :string
          | :object
          | :null
          | :ecma_array
          | :object_end
          | :strict_array
          | :date
          | :long_string
          | :xml
          | :typed_object
          | :switch

  @data_types %{
    0x0 => :number,
    0x1 => :boolean,
    0x2 => :string,
    0x3 => :object,
    0x5 => :null,
    0x8 => :ecma_array,
    0x9 => :object_end,
    0xA => :strict_array,
    0xB => :date,
    0xC => :long_string,
    0xF => :xml,
    0x10 => :typed_object,
    0x11 => :switch
  }

  @doc """
  new/2 create a new AMF0 message
  """
  def new(body) when is_integer(body) do
    type_ = get_data_type_code(:number)
    <<type_, body::float-64>>
  end

  def new(body, data_type \\ :string) do
    type_ = get_data_type_code(data_type)

    IO.inspect("Type: #{type_}")

    cond do
      is_binary(body) ->
        l = byte_size(body)
        <<type_, 0x0, l>> <> body

      is_integer(body) ->
        <<type_, 0x0, 2>>

      # TODO: Remove this
      true ->
        throw("Not implemented")
    end
  end

  defp get_data_type_code(data_type) do
    @data_types |> Enum.filter(fn {k, v} -> v == data_type end) |> List.first() |> elem(0)
  end

  # TOOD: Remove and rename

  defstruct [:amf, :body, :command, :length, :marker, :tail, :version]

  @type t :: %__MODULE__{
          amf: nil,
          body: nil,
          command: nil,
          length: nil,
          marker: nil,
          tail: nil,
          version: nil
        }

  def decode(<<0x03, msg::binary>>) do
    decode_message(msg, %{})
  end

  defp decode_message(<<>>, obj), do: Map.delete(obj, nil)

  defp decode_message(msg, obj) do
    {k, msg} = decode_message_key(msg)
    {v, msg} = decode_message_value(msg)

    decode_message(msg, Enum.into(obj, %{k => v}))
  end

  defp decode_message_key(<<0x0, 0x0, 0x09>>), do: {nil, ""}

  defp decode_message_key(<<size::size(16), msg::binary>>) do
    k = binary_part(msg, 0, size)
    <<_key::binary-size(size), msg::binary>> = msg
    {k, msg}
  end
  
  defp decode_message_value(<<0x02, size::size(16), msg::binary>>) do
    v = binary_part(msg, 0, size)
    <<_value::binary-size(size), msg::binary>> = msg
    {v, msg}
  end
  
  defp decode_message_value(<<0, v::float-64, msg::binary>>), do: {v, msg}

  defp decode_message_value(<<>>), do: {nil, <<>>}
end
