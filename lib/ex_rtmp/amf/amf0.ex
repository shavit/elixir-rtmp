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
    #0x9 => :object_end,
    0xA => :strict_array,
    #0xB => :date,
    0xC => :long_string,
    #0xF => :xml,
    #0x10 => :typed_object,
    #0x11 => :switch
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

  # TODO: Change signature to be able to decode nested objects
  def decode(msg), do: decode(msg, [])
  def decode(<<>>, objects) when is_list(objects), do: objects

  def decode(<<0x2, size::size(16), msg::binary>>, objects) do
    v = binary_part(msg, 0, size)
    <<_value::binary-size(size), rest::binary>> = msg
    decode(rest, [v | objects])
  end

  def decode(<<0x8, size::size(32), msg::binary>>, objects) do
    #v = binary_part(msg, 0, size)
    <<_value::binary-size(size), rest::binary>> = msg
    decode(rest, [size | objects])
  end

  def decode(<<0x0A, size::size(32), rest::binary>>, objects) do
    {value, rest} = decode_array(rest, size, [])
    decode(rest, [value | objects])
  end

  def decode(<<0x3::8, rest::binary>>, objects), do: decode_object(rest, objects)


  def decode(<<0x0, num::float, rest::binary>>, objects), do: decode(rest, [num | objects])
  def decode(<<0x1, 0x1, rest::binary>>, objects), do: decode(rest, [true | objects])
  def decode(<<0x1, 0x0, rest::binary>>, objects), do: decode(rest, [false | objects])
  def decode(<<0x5, rest::binary>>, objects), do: decode(rest, [nil | objects])
  def decode(unsupported, objects), do: decode(<<>>, [{:error, unsupported: unsupported} | objects])
  
  defp decode_array(<<0x0, num::float-64, rest::binary>>, i, nums) 
  when i > 0, do: decode_array(rest, i - 1, [num | nums])
  defp decode_array(rest, 0, nums) when is_list(nums), 
  do: {Enum.reverse(nums), rest} 

  defp decode_object(:eof, [_h | objects]), do: Enum.reverse(objects)
  defp decode_object(rest, objects) when is_binary(rest) and is_list(objects) do
      with {k, rest} <- decode_object_key(rest),
      {v, rest} <- decode_object_value(rest) do
        decode_object(rest, [%{k => v} | objects])
      end
  end

  # TODO: Should have the same return signature 
  defp decode_object_key(<<0x0, 0x0, 0x09>>), do: {:error, :eof}
  defp decode_object_key(<<0x0, n::8, rest::binary>>) do
    <<v::binary-size(n), rest::binary>> = rest
    {v, rest}
  end 

  defp decode_object_value(<<0x2, 0x0, n::8, rest::binary>>) do 
    <<v::binary-size(n), rest::binary>> = rest
    {v, rest}
  end

  defp decode_object_value(<<0, v::float-64, rest::binary>>), do: {v, rest}
  defp decode_object_value(:eof), do: {:error, :eof}
end
