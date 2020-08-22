defmodule ExRTMP.AMF do
  @moduledoc """
  `ExRTMP.AMF` reader and writer


  """
  alias ExRTMP.AMF.AMF0
  alias ExRTMP.AMF.AMF3

  defstruct [:amf, :body, :command, :length, :marker, :tail, :version]

  @doc """
  new/2 creates a new AMF message

    ## Options
      - :amf - The AMF version. Integer: 0, 3.

  """
  def new(m, opts \\ []) do
    case Keyword.get(opts, :amf) do
      nil -> AMF0.new(m, opts)
      0 -> AMF0.new(m, opts)
      3 -> AMF3.new(m, opts)
    end
  end

  def decode(msg) do
    msg
  end

  @doc """
  encode/1 encodes a message
  """
  def encode(struct, opts \\ []) when is_map(struct) do
    struct
    |> Enum.map(fn {k, v} ->
      encode_key(k) <> encode_string(v)
    end)
    |> Enum.join()
    |> encode_header(opts)
  end

  defp encode_header(body, _opts) do
    # It need ot read it from the struct
    csid = 1
    fmt = <<0::2, csid::6>>
    timestamp = :erlang.timestamp() |> elem(0)
    message_length = byte_size(body)

    header = fmt <> <<timestamp::unit(8)-size(3), message_length::unit(8)-size(3)>>
    header <> body
  end

  @doc """
  encode_key/1 encodes AMF object key
  """
  def encode_key(key) when is_binary(key) do
    <<byte_size(key)::unsigned-integer>> <> key
  end

  def encode_key(key) when is_atom(key) do
    key |> Atom.to_string() |> encode_key()
  end

  @doc """
  encode_number/1 encodes AMF number value

  The format is IEEE 64-bit double-precision floating point
  """
  def encode_number(value) do
    if is_number(value) do
      <<0x0, value::float-64>>
    else
      {:error, "invalid input"}
    end
  end

  @doc """
  encode_boolean/1 encodes AMF boolean value
  """
  def encode_boolean(value) do
    case value do
      false -> <<0x01, 0x00>>
      true -> <<0x01, 0x01>>
      0 -> <<0x01, 0x0>>
      1 -> <<0x01, 0x01>>
      _ -> {:error, "invalid input"}
    end
  end

  @doc """
  encode_string/1 encodes AMF string value

  It encodes 16-bit and 32-bit length strings
  """
  def encode_string(value) do
    vsize = byte_size(value)

    cond do
      vsize <= 0x10000 -> <<0x02, vsize::size(16), value::binary>>
      vsize <= 0x7FFFFFFF -> <<0x02, vsize::size(32), value::binary>>
      true -> <<>>
    end
  end

  @doc """
  encode_object/1 encodes AMF object value
  """
  def encode_object(value) do
    if is_map(value) do
    else
      {:error, "invalid input"}
    end
  end

  @doc """
  encode_null/1 encodes AMF null value
  """
  def encode_null(value) do
    if is_nil(value) do
      <<0x05>>
    else
      {:error, "invalid input"}
    end
  end

  @doc """
  encode_array/1 encodes AMF array value
  """
  def encode_array([]), do: []

  def encode_array([value | _rest] = arr) do
    arr_size = Enum.count(arr)
    <<0x08, arr_size::size(4)-unit(8)>> <> encode_string(value)
  end

  @doc """
  encode_date/1 encodes date value
  """
  def encode_date(value) do
    <<0x0B, value::float-64>>
  end
end
