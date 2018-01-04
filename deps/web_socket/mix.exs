defmodule WebSocket.Mixfile do
  use Mix.Project

  def project do
    [app: :web_socket,
     version: "0.1.0",
     elixir: "~> 1.0",
     name: "WebSocket",
     source_url: "https://github.com/slogsdon/plug-web-socket",
     homepage_url: "https://github.com/slogsdon/plug-web-socket",
     deps: deps,
     package: package,
     description: description,
     docs: [extras: ["README.md"],
	    main: "readme"],
     test_coverage: [tool: ExCoveralls]]
  end

  def application do
    [applications: [:logger, :plug, :cowboy, :poison]]
  end

  defp deps do
    [{:plug, "~> 1.2"},
     {:cowboy, "~> 1.0"},
     {:poison, "~> 3.0"},
     {:earmark, "~> 1.0", only: :dev},
     {:ex_doc, "~> 0.14", only: :dev},
     {:excoveralls, "~> 0.5", only: :test},
     {:dialyze, "~> 0.2", only: :test}]
  end

  defp description do
    """
    A quick start for using WebSockets in Plug applications.
    """
  end

  defp package do
    %{maintainers: ["Shane Logsdon"],
      files: ["lib", "priv", "mix.exs", "README.md", "LICENSE"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/slogsdon/plug-web-socket"}}
  end
end
