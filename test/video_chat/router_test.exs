defmodule VideoChatTest.Router do
  use ExUnit.Case, async: true
  use Plug.Test
  alias VideoChat.Router

  @opts Router.init([])

  describe "router" do

    test "should get index page" do
      conn = conn(:get, "/")
      conn = Router.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200
      assert {:ok, _binary, conn_resp} =  read_body(conn)
      assert %Plug.Conn{} = conn_resp
    end

    test "should get stream channesl" do
      conn = conn(:get, "/stream/channels")
      conn = Router.call(conn, @opts)
      assert conn.status == 200
    end

    test "should ping when stream started" do
      conn = conn(:post, "/stream/publish")
      conn = Router.call(conn, @opts)

      assert conn.status == 200
      assert {:ok, _binary, conn_resp} =  read_body(conn)
      assert %Plug.Conn{} = conn_resp
    end

    test "should ping when playing stream" do
      conn = conn(:post, "/stream/play")
      conn = Router.call(conn, @opts)

      assert conn.status == 200
      assert {:ok, _binary, conn_resp} =  read_body(conn)
      assert %Plug.Conn{} = conn_resp
    end

    test "should ping when ending stream" do
      conn = conn(:post, "/stream/end")
      conn = Router.call(conn, @opts)

      assert conn.status == 200
      assert {:ok, _binary, conn_resp} =  read_body(conn)
      assert %Plug.Conn{} = conn_resp
    end

  end

end
