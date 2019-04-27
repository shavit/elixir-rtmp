defmodule VideoChat.Mixfile do
  use Mix.Project

  def project do
    [app: :video_chat,
     version: "0.2.0",
     elixir: "~> 1.8.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [extra_applications: [:logger],
     mod: {VideoChat, []}]
  end
end
