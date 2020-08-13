defmodule ExRTMP.ConnectionTest do
  use ExUnit.Case
  alias ExRTMP.Server

  setup do
    {:ok, pid} = Server.start_link(port: 3300)
    %{server: pid}
  end

  describe "connection" do
    alias ExRTMP.Connection

    test "start_link/3 starts a connection process", %{server: server} do
      assert {:error, _reason} = Connection.start_link(nil)
      assert {:ok, _pid} = Connection.start_link(server: server)
    end

    test "register_client/2 call the server to register a client", %{server: server} do
      {:ok, pid} = Connection.start_link([])
      assert :ok = Connection.register_client(pid, %{server: server, socket: nil})
    end
  end
end
