defmodule VideoChat.RTMP.AMF do
  @moduledoc """
  AMF0 reader and writer

  Command messages have message type value of 20 for AMF0, and 17 for AMF3.
    Each command consists of a name, transaction ID and object

  https://www.adobe.com/content/dam/acom/en/devnet/pdf/amf0-file-format-specification.pdf
  https://en.wikipedia.org/wiki/Action_Message_Format
  """
  defstruct [:body, :command, :length, :marker]

  @type t :: %__MODULE__{
    body:                 nil,
    command:              nil,
    length:               nil,
    marker:              nil
  }

  @type command :: :connect | :call | :close | :create_stream

  # TODO: Replace the order
  @data_types %{
    number_marker:                0x00,
    boolean_marker:               0x01,
    string_marker:                0x02,
    object_marker:                0x03,
    movieclip_marker:             0x04,
    null_marker:                  0x05,
    undefined_marker:             0x06,
    reference_marker:             0x07,
    ecma_array_marker:            0x08,
    object_end_marker:            0x09,
    strict_array_marker:          0x0a,
    date_marker:                  0x0b,
    long_string_marker:           0x0c,
    unsupported_marker:           0x0d,
    recordset_marker:             0x0e,
    xml_document_marker:          0x0f,
    typed_object_marker:          0x10,
    avmplus_object_marker:        0x11,
  }

  def parse(<<type_value::bytes-size(1), body::bits>>) do
    <<length::unsigned-16, message::bits>> = body
    # TODO: Replace the exception with a return value
    if length > byte_size(message), do: throw "Invalid message: The message length exceeds the specified size"

    %__MODULE__{
       body: binary_part(message, 0, length),
       command: nil,
       length: length,
       marker: get_data_type_by(type_value)
     }
  end

  # TODO: Remove this
  defp get_data_type_by(value) do
    @data_types
    |> Enum.filter(fn {_k, v} -> <<v>> == value end)
    |> Enum.map(fn {k, _v} -> k end)
    |> List.first
  end

end
