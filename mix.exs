defmodule LogicVisualizer.MixProject do
  use Mix.Project

  def project do
    [
      app: :logic_visualizer,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Logic Visualizer",
      source_url: "https://github.com/yourusername/logic_visualizer"
    ]
  end

  def application do
    [
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp deps do
    [
      {:hol, "~> 1.0.1"},
      {:nimble_parsec, "~> 1.3"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:earmark, "~> 1.4", only: :dev}
    ]
  end

  defp description do
    "A comprehensive Elixir project for parsing and visualizing logical expressions using HOL library"
  end

  defp package do
    [
      name: "logic_visualizer",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/yourusername/logic_visualizer"}
    ]
  end
end