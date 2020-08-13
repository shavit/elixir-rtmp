defmodule ExRTMPTest do
  use ExUnit.Case
  alias ExRTMP.Server

  describe "rtmp server" do
    test "start_link/2 accept server options" do
      assert {:ok, _pid} = Server.start_link(port: 3100)
      assert {:ok, _pid} = Server.start_link(port: 3101)
      assert {:ok, _pid} = Server.start_link(port: 3102)
    end
  end
end
