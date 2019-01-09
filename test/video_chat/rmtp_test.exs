defmodule VideoChat.RTMPTest do
  use ExUnit.Case

  describe "rtmp server" do

    test "start_link/2 accept server options" do
      {:error, _message} = VideoChat.RTMP.start_link {}
      {:error, _message} = VideoChat.RTMP.start_link {3000}
      {:error, _message} = VideoChat.RTMP.start_link %{}
      {:error, _message} = VideoChat.RTMP.start_link []

      assert {:ok, _pid} = VideoChat.RTMP.start_link {3000, :server_1}
      assert {:ok, _pid} = VideoChat.RTMP.start_link {3001, :server_2}
      assert {:ok, _pid} = VideoChat.RTMP.start_link {3002, :server_3}
      assert {:ok, _pid} = VideoChat.RTMP.start_link {3003, :server_4}
    end
  end
end
