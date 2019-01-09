defmodule VideoChat.RTMP.ConnectionTest do
  use ExUnit.Case

  describe "connection" do
    alias VideoChat.RTMP.Connection

    test "start_link/3 starts a connection process" do
      assert {:ok, pid} = Connection.start_link nil, nil, []
      assert {:ok, pid2} = Connection.start_link pid, nil, []
      assert {:ok, _pid} = Connection.start_link pid, pid2, []
    end

    test "register_client/2 call the server to register a client" do
      {:ok, pid} = Connection.start_link nil, nil, []
      assert {:ok, server} = VideoChat.RTMP.start_link {3300, :test_server}
      assert :ok = Connection.register_client(pid, %{server: server, socket: nil})
    end
  end
end
