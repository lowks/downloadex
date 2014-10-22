defmodule ElixirDownloadManager.Mixfile do
  use Mix.Project

  def project do
    [app: :downloadex,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end


  def application do
    [applications: [:logger],
     mod: {DownloadEx, []}]
  end


  defp deps do
    [
      {:exactor, "~> 2.0.0"},
      {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.0"},
      {:httpotion, github: "kemonomachi/httpotion"},
      {:tempfile, github: "lowks/tempfile"}
    ]
  end
end
