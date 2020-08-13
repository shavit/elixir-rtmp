defmodule ExRTMP.ConnectionTest do
  use ExUnit.Case
  alias ExRTMP.Server

  setup do
    {:ok, pid} = Server.start_link(port: 3300)
    %{server: pid}
  end

  describe "connection" do
    alias ExRTMP.Connection

    test "start_link/3 starts a connection process" do
      assert {:ok, pid} = Connection.start_link(nil, nil, [])
      assert {:ok, pid2} = Connection.start_link(pid, nil, [])
      assert {:ok, _pid} = Connection.start_link(pid, pid2, [])
    end

    test "register_client/2 call the server to register a client", %{server: server} do
      {:ok, pid} = Connection.start_link(nil, nil, [])
      assert :ok = Connection.register_client(pid, %{server: server, socket: nil})
    end
  end
end
