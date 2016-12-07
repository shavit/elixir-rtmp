defmodule VideoChat.Writer do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(:ok) do
    # For debugging
    # Log using a different process
    # {{_year,_month,_day},{h,m,s}} = :calendar.local_time
    # System.cmd("sh", ["bin/read_string", "[#{h}:#{m}:#{s}] Started from Eixir"])

    # Listen to incoming streams on 3002
    # System.cmd(Path.join([System.cwd, "bin", "read_hls"]), ["-v"])

    # Start and wait for messages
    IO.inspect "---> Starting writer"
    pid = spawn fn ->
      System.cmd("sh", [
          Path.join([System.cwd, "bin", "read_udp_in"])
        ], into: IO.stream(:stdio, :line))
      end

    # {:ok, System.get_pid}
    {:ok, pid}
  end
end
