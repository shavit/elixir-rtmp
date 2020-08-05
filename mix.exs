defmodule VideoChat.Mixfile do
  use Mix.Project

  def project do
    [
      app: :video_chat,
      version: "0.2.0",
      elixir: "~> 1.10.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp deps do
    [{:credo, "~> 0.8", only: [:dev, :test], runtime: false}]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [extra_applications: [:logger], mod: {VideoChat, []}]
  end
end
