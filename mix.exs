defmodule OopsLogger.MixProject do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :oops_logger,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      dialyzer: [
        flags: [:unmatched_returns, :error_handling, :race_conditions, :underspecs]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :docs, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:test, :dev], runtime: false}
    ]
  end

  defp description do
    "Elixir Logger for Linux Ramoops"
  end

  defp package do
    [
      maintainers: ["Matt Ludwigs"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/smartrent/oops_logger"},
      organization: "smartrent"
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: "https://github.com/smartrent/oops_logger"
    ]
  end
end
