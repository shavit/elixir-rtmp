defmodule FileEncoderTest do
  use ExUnit.Case
  import VideoChat.Encoding.FileSupervisor
  doctest VideoChat

  setup %{} do
    {:ok, pid} = start_link(name: :file_encoding_supervisor, workers: 3)

    %{pid: pid}
  end

  test "should start n supervisor workers", %{pid: pid} do
    %{active: active,
      specs: _specs,
      supervisors: _supervisors,
      workers: workers} = Supervisor.count_children(pid)

    assert active == 3
    assert workers == 3
  end

  test "should start multiple different supervisors" do
    assert {:ok, pid1} = start_link(name: :file_encoding_supervisor_1, workers: 3)
    assert {:ok, pid2} = start_link(name: :file_encoding_supervisor_2, workers: 2)
    assert {:ok, pid3} = start_link(name: :file_encoding_supervisor_3, workers: 1)
    assert pid1 != pid2 != pid3
  end

  test "supervisor should start multiple encoding tasks", %{pid: pid} do
    assert {:ok, _pid} = start_child(pid, [id: :one, video: :random_video, res: :mp4_320])
    assert {:ok, _pid} = start_child(pid, [id: :two, video: :random_video, res: :mp4_320])
  end
end
