defmodule GPGex.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/sheerlox/gpg_ex"
  @docs_url "http://hexdocs.pm/gpg_ex"

  def project do
    [
      app: :gpg_ex,
      version: "1.0.0-alpha.4",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  defp deps do
    [
      {:elixir_uuid, "~> 1.2"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp dialyzer() do
    [
      plt_local_path: "priv/plts/project.plt",
      plt_core_path: "priv/plts/core.plt"
    ]
  end

  defp description() do
    """
    A simple wrapper to run GPG commands.
    """
  end

  defp package() do
    [
      maintainers: ["Pierre Cavin"],
      licenses: ["Apache-2.0"],
      links: %{
        GitHub: @source_url,
        Changelog: "#{@docs_url}/changelog.html"
      }
    ]
  end

  defp docs() do
    [
      name: "GPGex",
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      canonical: @docs_url,
      extras: ["README.md", "CHANGELOG.md", "LICENSE.md"]
    ]
  end
end
