defmodule EncodingSupervisorTest do
  use ExUnit.Case
  doctest VideoChat

  setup do
    # import Supervisor.Spec
    {:ok, pid} = VideoChat.Encoding.Supervisor.start_link([name: :supervisor_test])
    Supervisor.start_child(pid, [])
    # IO.inspect Supervisor.start_child(pid,
    #   worker(VideoChat.Encoding.Encoder, [id: :encoder_worker_one]))

    %{pid: pid}
  end

  test "should start a worker", %{pid: pid} do
    assert pid != nil
    %{active: active,
      specs: _specs,
      supervisors: _supervisors,
      workers: _workers} = Supervisor.count_children(pid)

    assert active > 0
    IO.puts "---> Active children: #{active}"
  end

end
