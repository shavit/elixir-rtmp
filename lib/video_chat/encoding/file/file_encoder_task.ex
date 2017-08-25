defmodule VideoChat.Encoding.FileEncoderTask do
  use Task

  def start_link(opts) do
    Task.start_link(__MODULE__, :work, [opts])
  end

  def work(opts) do
    {:res, n} = Enum.at(opts, 2)
    _res = get_resolution(n)
    # IO.inspect "---> Starting task #{res}"

    # TODO: Execute the encoder binary
    :timer.sleep(2000)
  end

  defp get_resolution(i) do
    case i do
      0 -> "mp4_240"
      1 -> "mp4_320"
      2 -> "mp4_480"
      _ -> "mp4_640"
    end
  end
end
