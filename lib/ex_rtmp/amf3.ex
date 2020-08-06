defmodule ExRTMP.AMF3 do
  @moduledoc """
  AMF3 reader and writer

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
    0x7 => :xml,
    0x8 => :date,
    0x9 => :array,
    0xA => :object,
    0xB => :xml_end,
    0xC => :byte_array,
    0xD => :vector_int,
    0xE => :vector_uint,
    0xF => :vector_double,
    0x10 => :vector_object,
    0x11 => :dictionary
  }

  @doc """
  new/2 create a new AMF3 message
  """
  def new(body, data_type \\ :byte_array) do
    type_ = @data_types |> Enum.filter(fn {k, v} -> v == data_type end) |> List.first() |> elem(0)
    l = 1 + byte_size(body) * 2
    # TODO: Encode different types and lengths
    # <<type_, 0x0, l>> <> body <> <<0x9>>
    <<type_, l>> <> body
  end
end
