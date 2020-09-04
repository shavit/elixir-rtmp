defmodule ExRTMP.Chunk.BasicHeaderTest do
  use ExUnit.Case
  alias ExRTMP.Chunk.BasicHeader

  def assert_expected({m, f, args, expected}) do
    assert expected == apply(m, f, args)
  end

  describe "chunk basic header" do
    test "new/2 creates basic header type 1" do
      [
        {BasicHeader, :new, [1, :one], {:error, "id out of range"}},
        {BasicHeader, :new, [2, :one], {:error, "id out of range"}},
        {BasicHeader, :new, [3, :one], <<0::2, 3::6>>},
        {BasicHeader, :new, [4, :one], <<0::2, 4::6>>},
        {BasicHeader, :new, [63, :one], <<0::2, 63::6>>},
        {BasicHeader, :new, [64, :one], {:error, "id out of range"}}
      ]
      |> Enum.each(&assert_expected/1)
    end

    test "new/2 creates basic header type 2" do
      [
        # {BasicHeader, :new, [1, :two], {:error, "id out of range"}},
        # {BasicHeader, :new, [2, :two], {:error, "id out of range"}},
        # {BasicHeader, :new, [64, :two], <<0::2, 0::6, 0::8>>},
	{BasicHeader, :new, [64, :two], <<64, 0>>},
	{BasicHeader, :new, [65, :two], <<64, 1>>},
        # {BasicHeader, :new, [65, :two], <<0::2, 0::6, 1::8>>},
#        {BasicHeader, :new, [319, :two], <<0::2, 0::6, 319::8>>},
#        {BasicHeader, :new, [320, :two], {:error, "id out of range"}}
      ]
      |> Enum.each(&assert_expected/1)
    end

    test "new/2 creates basic header type 3" do
      [
#        {BasicHeader, :new, [1, :three], {:error, "id out of range"}},
#        {BasicHeader, :new, [2, :three], {:error, "id out of range"}},
#        {BasicHeader, :new, [63, :three], {:error, "id out of range"}},
#        {BasicHeader, :new, [64, :three], <<1::2, 1::6, 0::6>>},
        # {BasicHeader, :new, [100, :three], <<1::2, 1::6, 36::16>>},
        # {BasicHeader, :new, [200, :three], <<1::2, 1::6, 136::16>>},
#        {BasicHeader, :new, [65_599, :three], <<1::2, 1::6, 255::16>>},
        {BasicHeader, :new, [65_600, :three], {:error, "id out of range"}}
      ]
      |> Enum.each(&assert_expected/1)
    end
  end
end
