defmodule CLL.MixProject do
  use Mix.Project

  def project do
    [
      app: :cll,
      version: "0.2.0",
      elixir: "~> 1.7",
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :prod,
      dialyzer: [plt_add_apps: [:mix]],
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp description do
    """
    Data structure with circular linked-list behaviour in Elixir
    """
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
      {:propcheck, "~> 1.1", only: :test},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 1.5", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib/cll.ex", "mix.exs", "README*"],
      maintainers: ["Powell Kinney"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/pkinney/topo"}
    ]
  end

  defp aliases do
    [
      validate: [
        "clean",
        "compile --warnings-as-error",
        "format --check-formatted",
        "credo",
        "dialyzer"
      ]
    ]
  end
end
