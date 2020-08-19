defmodule ExRTMP.AMF do
  @moduledoc """
  `ExRTMP.AMF` reader and writer

  
  """

  def decode(msg) do
    msg
  end

  def encode_key(key) when is_binary(key) do
    <<byte_size(key)::unsigned-integer>> <> key
  end
end
