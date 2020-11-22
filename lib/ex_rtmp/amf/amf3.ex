defmodule ExRTMP.AMF.AMF3 do
  @moduledoc """
  `ExRTMP.AMF.AMF3` AMF3 reader and writer

  Command messages have message type value of 17 for AMF3.
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
  import Bitwise, only: [<<<: 2, >>>: 2, |||: 2, &&&: 2]

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
          :undefined
          | :null
          | false
          | true
          | :integer
          | :double
          | :string
          | :xml
          | :date
          | :array
          | :object
          | :xml_end
          | :byte_array
          | :vector_int
          | :vector_uint
          | :vector_double
          | :vector_object
          | :dictionary

  @data_types %{
    0x0 => :undefined,
    0x1 => :null,
    0x2 => false,
    0x3 => true,
    0x4 => :integer,
    0x5 => :double,
    0x6 => :string,
    # 0x7 => :xml,
    # 0x8 => :date,
    0x9 => :array,
    0xA => :object,
    # 0xB => :xml_end,
    # 0xC => :byte_array,
    0xD => :vector_int,
    0xE => :vector_uint,
    0xF => :vector_double
    # 0x10 => :vector_object,
    # 0x11 => :dictionary
  }

  for {k, v} <- @data_types do
    defp unquote(:"t_#{v}")(), do: unquote(k)
  end

  @doc """
  encode/1 encodes a new AMF3 message
  """
  def encode(nil), do: <<t_null()>>
  def encode(false), do: <<t_false()>>
  def encode(true), do: <<t_true()>>
  def encode(body) when is_float(body), do: <<t_double(), body::float-64>>
  def encode(k) when is_atom(k), do: k |> Atom.to_string() |> encode()

  def encode(body) when is_integer(body) do
    l = if body >= 0, do: body, else: (1 <<< 0x1D) + body
    head = do_encode_u29(l)
    <<t_integer(), head::binary>>
  end

  def encode(body) when is_integer(body) do
    l = if body >= 0, do: body, else: (1 <<< 0x1D) + body
    head = do_encode_u29(l)
    <<t_integer(), head::binary>>
  end

  def encode(body) when is_binary(body) do
    head = do_encode_u29(byte_size(body) <<< 1 ||| 1)
    <<t_string(), head::binary, body::binary>>
  end

  def encode(body) when is_list(body) do
    cond do
      Enum.empty?(body) -> do_encode_array([])
      Enum.all?(body, &is_map/1) -> do_encode_vector_object(body)
      Enum.any?(body, &(!is_number(&1))) -> do_encode_array(body)
      Enum.any?(body, &is_float/1) -> do_encode_vector_double(body)
      Enum.any?(body, &(&1 < 0)) -> do_encode_vector_int(body)
      Enum.all?(body, &(&1 >= 0)) -> do_encode_vector_uint(body)
    end
  end

  def encode(body) when is_map(body) do
    n_entries = Enum.count(body)

    body =
      body
      |> Map.to_list()
      |> Enum.map(fn {k, v} -> (k |> encode() |> strip_encoded_type()) <> encode(v) end)
      |> Enum.join()

    <<t_object(), n_entries::8, body::binary>>
  end

  def encode(_body), do: <<t_undefined()>>
  
  defp do_encode_u29(length) do
    case length do
      l when l in 0..0x7F ->
        <<l>>

      l when l in 0x80..0x3FFF ->
        <<l >>> 7 ||| 0x80, l >>> 0 &&& 0x7F>>

      l when l in 0x4000..0x1FFFFF ->
        <<l >>> 14 ||| 0x80, l >>> 0x7 ||| 0x80, l >>> 0 &&& 0x7F>>

      l when l in 0x200000..0x3FFFFFFF ->
        <<l >>> 0x16 ||| 0x80, l >>> 0xF ||| 0x80, l >>> 0x8 ||| 0x80, l >>> 0 &&& 0xFF>>

      _ ->
        :value_too_large
    end
  end
 
  defp do_encode_vector_object([h | _t]) when is_map(h) do
    {:error, :not_implemented}
  end

  defp do_encode_array([]), do: <<t_array(), 0x0>>
  defp do_encode_array(body) when is_list(body) do
    l = length(body)
    body = body |> Enum.map(&encode/1) |> Enum.join()
    <<t_array(), l::32>> <> body
  end

  defp do_encode_vector_double([h | _t] = body) when is_number(h) do
    l = Enum.reduce(body, <<>>, &(&2 <> <<&1::float-64>>))
    <<t_vector_double(), length(body)::32, l::binary>>
  end

  defp do_encode_vector_uint([h | _t] = body) when is_integer(h) do
    head = do_encode_u29(length(body) <<< 1 ||| 1)
    rest = Enum.reduce(body, <<>>, &(&2 <> <<&1::big-integer-size(32)>>))
    <<t_vector_uint(), head::binary, 0x0, rest::binary>>
  end

  defp do_encode_vector_int([h | _t] = body) when is_integer(h) do
    head = do_encode_u29(length(body) <<< 1 ||| 1)
    rest = Enum.reduce(body, <<>>, &(&2 <> <<&1::big-integer-size(32)>>))
    <<t_vector_int(), head::binary, 0x0, rest::binary>>
  end

  defp strip_encoded_type(bytes) when is_binary(bytes),
    do: binary_part(bytes, 1, byte_size(bytes) - 1)

  defp do_encode_u29(length) do
    case length do
      l when l in 0..0x7F ->
        <<l>>

      l when l in 0x80..0x3FFF ->
        <<l >>> 7 ||| 0x80, l >>> 0 &&& 0x7F>>

      l when l in 0x4000..0x1FFFFF ->
        <<l >>> 14 ||| 0x80, l >>> 0x7 ||| 0x80, l >>> 0 &&& 0x7F>>

      l when l in 0x200000..0x3FFFFFFF ->
        <<l >>> 0x16 ||| 0x80, l >>> 0xF ||| 0x80, l >>> 0x8 ||| 0x80, l >>> 0 &&& 0xFF>>

      _ ->
        :value_too_large
    end
  end

  @doc """
  decode/1 decodes AMF3 message
  """
  def decode(<<0x0, _rest::binary>>), do: {:error, :undefined}
  def decode(<<0x1, _rest::binary>>), do: {:ok, nil}
  def decode(<<0x2, _rest::binary>>), do: {:ok, false}
  def decode(<<0x3, _rest::binary>>), do: {:ok, true}

  def decode(<<0x4, msg::binary>>), do: {:ok, do_decode_u29(msg)}
  def decode(<<0x5, msg::float-64, _rest::binary>>), do: {:ok, msg}
  def decode(<<0x6, _msg::binary>>), do: {:error, :not_implemented}
  def decode(<<0x9, _msg::binary>>), do: {:error, :not_implemented}
  def decode(<<0xD, _msg::binary>>), do: {:error, :not_implemented}
  def decode(<<0xE, _msg::binary>>), do: {:error, :not_implemented}
  def decode(<<0xF, _msg::binary>>), do: {:error, :not_implemented}
  def decode(_msg), do: {:error, :invalid}

  defp do_decode_u29(data) do
    case data do
      <<0::1, b1::7, _rest::binary>> ->
        b1

     <<0::1, b1::7, 0x0::1, b2::7, _rest::binary>> ->
        b1 <<< 7 ||| b2

      <<0::1, b1::7, 0x1::1, b2::7, 0x0::1, b3::7, _rest::binary>> ->
        b1 <<< 14 ||| b2 <<< 7 ||| b3

      <<0::1, b1::7, 0x1::1, b2::7, 0x1::1, b3::7, b4::8, _rest::binary>> ->
        b1 <<< 22 ||| b2 <<< 15 ||| b3 <<< 8 ||| b4
    end
  end
end
