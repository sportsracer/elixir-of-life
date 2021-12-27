defmodule ElixirOfLife.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_of_life,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {ElixirOfLifeApp, []},
      extra_applications: [:logger, :wx]
    ]
  end

  defp deps do
    []
  end
end
