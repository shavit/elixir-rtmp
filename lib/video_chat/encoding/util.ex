defmodule VideoChat.Encoding.Util do

  @spec new(file_path :: String, output :: String) :: Map
  def new(file_path, output) do
    %{path: file_path, output: output, args: []}
  end

  @doc """
  Add option strings, key and value:
    ["-ac", "2"]
  """
  def add_option(cmd, opt) do
    Map.put(cmd, :args, Enum.concat(cmd.args, opt))
  end

  @doc """
  Build the command string
  """
  def to_command(cmd) do
    {"ffmpeg",
      ["-i", "#{cmd.path}"]
      |> Enum.concat(cmd.args)
      |> Enum.concat(["#{cmd.output}"])}
  end
end
