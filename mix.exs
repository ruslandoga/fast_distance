defmodule FastDistance.MixProject do
  use Mix.Project

  def project do
    [
      app: :fast_distance,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:exqlite, "~> 0.13.11"},
      {:benchee, "~> 1.1", only: :bench}
    ]
  end
end
