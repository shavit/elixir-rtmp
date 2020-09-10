defmodule ExRTMP.Chunk.MessageHeaderTest do
  use ExUnit.Case
  alias ExRTMP.Chunk.MessageHeader

  describe "message header" do
    test "decode/1 decodes message header" do
      tests =
        [
          <<2, 0, 0, 0, 0, 0, 6, 4, 0, 0, 0, 0, 0, 6, 17, 249, 187, 163>>
        ]
        |> Enum.each(fn x ->
          IO.inspect(MessageHeader.decode(x))
        end)
    end
  end
end
