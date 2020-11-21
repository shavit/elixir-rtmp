defmodule ExRTMP.Support.Fixtures do
  @moduledoc """
  Documentation for `ExRTMP.Support.Fixtures`
  """

  @doc """
  fixture_file/1 returns the contents of a file from the fixtures directory
  """
  def fixture_file(name) do
    [File.cwd!(), "test", "support", "fixtures", name <> ".bin"]
    |> Path.join()
    |> File.read!()
  end
end
