defmodule VideoChat.Encoding.FileSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    # :permanent - the child process is always restarted
    # :temporary - the child process is never restarted (not even when
    #   the supervisor’s strategy is :rest_for_one or :one_for_all)
    # :transient - the child process is restarted only if it terminates
    #   abnormally, i.e., with an exit reason other than :normal, :shutdown
    #   or {:shutdown, term}
    {:workers, workers} = Enum.at(opts, 1)
    children = for i <- 1..workers do
      worker(VideoChat.Encoding.FileEncoderTask,
        [Enum.concat(opts, [res: i])], restart: :transient, id: i)
    end

    supervise(children, strategy: :one_for_one)
  end

  def start_child(pid, opts) do
    {:id, id} = Enum.at(opts, 0)
    Supervisor.start_child(pid, worker(VideoChat.Encoding.FileEncoderTask,
        [opts], restart: :transient, id: id))
  end
end
