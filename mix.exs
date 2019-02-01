defmodule OopsLogger.MixProject do
  use Mix.Project

  def project do
    [
      app: :oops_logger,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
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
      {:ex_doc, "~> 0.19", only: [:test, :dev], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:test, :dev], runtime: false},
    ]
  end

  defp description do
    "Elixir Logger for Linux Ramoops"
  end

  defp package do
    [
      maintainers: ["Matt Ludwigs"],
      licenses: ["Proprietary"],
      links: %{"GitHub" => "https://github.com/smartrent/oops_logger"},
      organization: "smartrent"
    ]
  end
end
