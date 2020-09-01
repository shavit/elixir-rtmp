defmodule ExRTMP.ControlMessageTest do
  use ExUnit.Case
  alias ExRTMP.ControlMessage

  describe "control message" do
    test "new/1 creates a new control message" do
      msg = ControlMessage.new []
      assert is_binary(msg)
    end
  end
end
