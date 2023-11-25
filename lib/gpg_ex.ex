defmodule GPGex do
  @moduledoc """
  A simple wrapper to run GPG commands.

  Tested on Linux with `gpg (GnuPG) 2.2.27`.

  > ### Warning {: .warning}
  >
  > This is a pre-release version. As such, anything _may_ change
  > at any time, the public API _should not_ be considered stable,
  > and using a pinned version is _recommended_.

  ## Configuration

  You can specify an optional directory to be passed to `--homedir`.
  Without this option your default GPG keyring will be used.

      config :gpg_ex,
        gpg_home: "/tmp/gpg_ex_home"

  """

  @base_args ["--batch", "--status-fd=1"]

  @doc ~S"""
  Runs GPG with the given args.

  Returns parsed status messages and stdout rows separately in a tuple.

  ## Examples

      iex> {:ok, messages, stdout} = GPGex.cmd(["--recv-keys", "18D5DCA13E5D61587F552A1BDEB5A837B34DD01D"])
      iex> messages
      [
        "KEY_CONSIDERED 18D5DCA13E5D61587F552A1BDEB5A837B34DD01D 0",
        "IMPORTED DEB5A837B34DD01D GPGEx Test <spam@sherlox.io>",
        "IMPORT_OK 1 18D5DCA13E5D61587F552A1BDEB5A837B34DD01D",
        "IMPORT_RES 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0"
      ]
      iex> stdout
      [
        "key DEB5A837B34DD01D: public key \"GPGEx Test <spam@sherlox.io>\" imported",
        "Total number processed: 1",
        "imported: 1"
      ]

      iex> GPGex.cmd(["--delete-keys", "18D5DCA13E5D61587F552A1BDEB5A837B34DD01D"])
      {:ok, [], []}

      iex> GPGex.cmd(["--recv-keys", "91C8AFC4674BF0963E7A90CEB7FFBE9D2DF23D67"])
      {:error, ["FAILURE recv-keys 167772218"], ["keyserver receive failed: No data"]}

  """
  @spec cmd([String.t()]) :: {:ok | :error, [String.t()], [String.t()]}
  def cmd(args) when is_list(args) do
    {res, code} =
      System.cmd(
        "gpg",
        base_args() ++ args,
        into: [],
        stderr_to_stdout: true
      )

    [stdout, messages] = process_output(res)

    case code do
      0 -> {:ok, stdout, messages}
      _ -> {:error, stdout, messages}
    end
  end

  @doc """
  Same as `cmd/1` but raises a
  `RuntimeError` if the command fails.
  """
  @spec cmd!([String.t()]) :: {[String.t()], [String.t()]}
  def cmd!(args) when is_list(args) do
    case cmd(args) do
      {:ok, stdout, messages} ->
        {stdout, messages}

      {:error, stdout, _} ->
        raise RuntimeError,
              "GPG command failed with: #{stdout}"
    end
  end

  defp process_output(stdout) do
    stdout
    |> Enum.join()
    |> String.split("\n", trim: true)
    |> Enum.split_with(&String.starts_with?(&1, "[GNUPG:]"))
    |> Tuple.to_list()
    |> Enum.map(&cleanup_lines(&1))
  end

  defp cleanup_lines(lines) do
    lines
    |> Enum.map(fn line -> String.replace(line, ~r/(\[GNUPG:\]|gpg:)\s/, "") |> String.trim() end)
  end

  defp base_args() do
    case Application.fetch_env(:gpg_ex, :gpg_home) do
      {:ok, gpg_home} -> ["--homedir", gpg_home] ++ @base_args
      _ -> @base_args
    end
  end
end
