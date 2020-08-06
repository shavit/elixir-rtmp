defmodule ExRTMPTest do
  use ExUnit.Case

  describe "rtmp server" do
    test "start_link/2 accept server options" do
      {:error, _message} = ExRTMP.start_link({})
      {:error, _message} = ExRTMP.start_link({3000})
      {:error, _message} = ExRTMP.start_link(%{})
      {:error, _message} = ExRTMP.start_link([])

      assert {:ok, _pid} = ExRTMP.start_link({3000, :server_1})
      assert {:ok, _pid} = ExRTMP.start_link({3001, :server_2})
      assert {:ok, _pid} = ExRTMP.start_link({3002, :server_3})
      assert {:ok, _pid} = ExRTMP.start_link({3003, :server_4})
    end
  end
end
