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

  defstruct [:amf, :csid, :body, :command, :length, :marker, :tail, :version]

  @type t :: %__MODULE__{
          amf: nil,
          body: nil,
          command: nil,
          length: nil,
          marker: nil,
          tail: nil,
          version: nil
        }

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

  for {k, v} <- @data_types do
    defp unquote(:"t_#{v}")(), do: unquote(k)
  end

  @doc """
  new/2 create a new AMF0 message
  """
  def new(m, opts) when is_list(opts) do
    %__MODULE__{
      amf: 0,
      csid: opts[:csid],
      body: encode(m)
    }
  end

  @doc """
  encode/1 encodes a new AMF0 message
  """
  def encode(body) when is_number(body),
    do: <<t_number(), body::float-64>>

  def encode(true), do: <<t_boolean(), 1>>
  def encode(false), do: <<t_boolean(), 0>>

  def encode(body) when is_binary(body) do
    if (l = byte_size(body)) > 0xFFFF do
      <<t_long_string(), l::32, body::binary>>
    else
      <<t_string(), l::16, body::binary>>
    end
  end

  def encode(body) when is_map(body) do
    body =
      body |> Map.to_list() |> Enum.map(fn {k, v} -> encode(k) <> encode(v) end) |> Enum.join()

    <<t_object()::16>> <> body <> <<0::size(8)>>
  end

  def encode(nil), do: <<t_null()>>

  def encode([h | _t] = body) when is_number(h) do
    l = length(body)
    body = body |> Enum.map(&encode/1) |> Enum.join()
    <<t_strict_array(), l::32>> <> body
  end

  def encode([_h | _t] = body) do
    l = length(body)
    body = body |> Enum.map(&encode/1) |> Enum.join()
    <<t_ecma_array(), l::32>> <> body
  end

  def encode(_unsupported), do: {:error, :unsupported}

  def decode(<<0x2, size::size(16), msg::binary>>) do
    v = binary_part(msg, 0, size)
    <<_value::binary-size(size), msg::binary>> = msg
    {v, msg}
  end

  def decode(<<0x8, size::size(32), msg::binary>>) do
    v = binary_part(msg, 0, size)
    <<_value::binary-size(size), msg::binary>> = msg
    size
  end

  def decode(<<0x0A, size::size(32), msg::binary>>) do
    v = binary_part(msg, 0, size)
    <<_value::binary-size(size), msg::binary>> = msg
    msg
  end

  def decode(<<0x3::16, 0x0>>), do: %{}

  def decode(<<0x3::16, rest::binary>>) do
    rest
  end

  def decode(<<0x0, num::float, rest::binary>>), do: {num, rest}
  def decode(<<0x1, 0x1, rest::binary>>), do: {true, rest}
  def decode(<<0x1, 0x0, rest::binary>>), do: {false, rest}
  def decode(<<0x5, rest::binary>>), do: {nil, rest}

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
