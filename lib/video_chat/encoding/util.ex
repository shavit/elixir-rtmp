defmodule VideoChat.Encoding.Util do

  @spec new(file_path :: String, output :: String) :: Map
  def new(file_path, output) do
    %{path: file_path, output: output, args: []}
  end

  @doc """
  Add an option string, key and value:
    -ac 2
  """
  def add_option(cmd, opt) do
    cmd |> Map.put(:args, Enum.concat(cmd.args, opt))
  end

  @doc """
  Build the command string
  """
  def to_command(cmd) do
    {"ffmpeg",
      Enum.concat(["-i #{cmd.path}" | cmd.args], ["-o #{cmd.output}"])}
  end
end
