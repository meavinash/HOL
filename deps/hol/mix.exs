defmodule Hol.MixProject do
  use Mix.Project

  @source_url "https://github.com/Jonaloew/HOL"

  def project do
    [
      app: :hol,
      version: "1.0.1",
      elixir: "~> 1.17.3",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: @source_url,
      docs: [
        main: "readme",
        # favicon: "path/to/favicon.png",
        # logo: "path/to/logo.png",
        extras: ["README.md", "docs_extra_files/unification_examples.livemd"]
      ],
      description: "A higher order logic pre-unification implementation",
      package: package()
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
      # Benchmarking
      {:benchee, "~> 1.0", only: :dev},
      # Code Analyzer
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      # Code Analyzer
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      # Documentation
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  def package do
    [
      licenses: ["Apache-2.0"],
      maintainers: ["Jonathan Löw"],
      files: ~w(config docs_extra_files lib test LICENSE mix.exs README.md),
      links: %{
        "GitHub" => @source_url
      }
    ]
  end
end
