# GPGex

A simple wrapper to run GPG commands.

Tested on Linux with `gpg (GnuPG) 2.2.27`.

> [!WARNING]  
> This is a pre-release version. As such, anything _may_ change
> at any time, the public API _should not_ be considered stable,
> and using a pinned version is _recommended_.

## Installation

This library relies on `gpg` being available in your PATH.

The package can be installed by adding `gpg_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gpg_ex, "0.1.0"}
  ]
end
```

Full documentation can be found at [https://hexdocs.pm/gpg_ex](https://hexdocs.pm/gpg_ex).

## Versioning

This project follows the principles of [Semantic Versioning (SemVer)](https://semver.org/).
