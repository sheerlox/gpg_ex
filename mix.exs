defmodule GPGex.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/sheerlox/gpg_ex"
  @docs_url "http://hexdocs.pm/gpg_ex"

  def project do
    [
      app: :gpg_ex,
      version: "0.1.0",
      elixir: "~> 1.12.3 or ~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
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
