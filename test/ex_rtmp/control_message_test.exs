defmodule ExRTMP.ControlMessageTest do
  use ExUnit.Case
  alias ExRTMP.ControlMessage

  describe "control message" do
    test "new/1 creates a new control message" do
      msg = ControlMessage.new []
      assert is_binary(msg)
    end

    test "client_pinged/2 creates a ping control message" do
      # <<0, 1, 0, 0, 6, 63>>
      csid = 10
      stream_id = 11
      msg = <<csid::16, _timestamp::8*4>> = ControlMessage.client_pinged csid, stream_id
    end
  end
end
