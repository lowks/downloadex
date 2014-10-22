defmodule ElixirDownloadManager.Mixfile do
  use Mix.Project

  def project do
    [app: :elixir_download_manager,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :httpoison],
     mod: {ElixirDownloadManager, []}]
  end

  # Type `mix help deps` for more examples and options
  defp deps do
    [
      #{:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.0"},
      #{:httpotion, github: "kemonomachi/httpotion"},
      {:erlubi, github: "krestenkrab/erlubi"},
      {:httpoison, "~> 0.5"}
    ]
  end
end
