defmodule ExRTMP.Chunk.BasicHeaderTest do
  use ExUnit.Case
  alias ExRTMP.Chunk.BasicHeader

  def assert_expected({m, f, args, expected}) do
    assert expected == apply(m, f, args)
  end

  describe "chunk basic header" do
    test "new/2 creates basic header type 1" do
      #BasicHeader.new 3, :one
      [
	{BasicHeader, :new, [1, :one], {:error, "id out of range"}},
	{BasicHeader, :new, [2, :one], {:error, "id out of range"}},
	{BasicHeader, :new, [3, :one], <<0::2, 3::6>>},
	{BasicHeader, :new, [4, :one], <<0::2, 4::6>>},
	{BasicHeader, :new, [65_599, :one], <<0::2, 65_599::6>>},
	{BasicHeader, :new, [65_600, :one], {:error, "id out of range"}},
      ] |> Enum.each(&assert_expected/1)
    end
  end
end

