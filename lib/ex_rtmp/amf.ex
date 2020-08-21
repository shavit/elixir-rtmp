defmodule ExRTMP.AMF do
  @moduledoc """
  `ExRTMP.AMF` reader and writer


  """

  def decode(msg) do
    msg
  end

  @doc """
  encode_key/1 encodes AMF object key
  """
  def encode_key(key) when is_binary(key) do
    <<byte_size(key)::unsigned-integer>> <> key
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
  """
  def encode_string(value) do
    if is_binary(value) do
      <<0x02, byte_size(value)::size(16), value::binary>>
    else
      {:error, "invalid input"}
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
end
