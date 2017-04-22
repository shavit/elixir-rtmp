defmodule VideoChat.Encoding.Supervisor do
  use Supervisor

  def start_link(_opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, name: :encoding_supervisor)
  end

  def init(:ok) do
    # :permanent - the child process is always restarted
    # :temporary - the child process is never restarted (not even when
    #   the supervisor’s strategy is :rest_for_one or :one_for_all)
    # :transient - the child process is restarted only if it terminates
    #   abnormally, i.e., with an exit reason other than :normal, :shutdown
    #   or {:shutdown, term}
    children = [
      # No point to restart
      worker(VideoChat.Encoding.Encoder, [id: :one], restart: :transient),
      # worker(VideoChat.Encoding.Encoder, [id: :encoder], restart: :transient),
      # worker(VideoChat.Encoding.Encoder, [id: :two], restart: :transient),
    ]

    supervise(children, strategy: :one_for_one)
  end

end
