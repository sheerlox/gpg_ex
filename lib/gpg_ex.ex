defmodule GPGex do
  @moduledoc """
  A simple wrapper to run GPG commands.

  Tested on Linux with `gpg (GnuPG) 2.2.27`.

  > ### Warning {: .warning}
  >
  > This is a pre-release version. As such, anything _may_ change at any time, the public
  > API _should not_ be considered stable, and using a pinned version is _recommended_.

  ## Configuration

  You can configure the library with both the `global_keystore` key in the configuration
  and the `keystore` option in functions.

  The `keystore` option in functions takes precedence over the `global_keystore` configuration,
  and if none of these are provided, your default GPG keystore (i.e. "homedir") will be used.

  You can specify an optional directory to be passed to `--homedir`, and an optional filename
  to be passed to `--keyring` (in which case `--no-default-keyring` will be automatically added).

      config :gpg_ex,
        global_keystore: %{
          path: "priv/global_gpg_homedir",
          keyring: "global_gpg_keyring.kbx"
        }

  _Note: the following configuration is used in the "Examples" section throughout this documentation:_

      config :gpg_ex,
        global_keystore: %{
          path: "/tmp/gpg_ex_keystore"
        }

  """
  alias GPGex.Keystore

  @base_args ["--batch", "--status-fd=1"]

  @doc ~S"""
  Runs GPG with the given args.

  Returns parsed status messages and stdout rows separately in a tuple.

  Also returns the command arguments if it failed.

  See [gnupg/doc/DETAILS](https://github.com/gpg/gnupg/blob/master/doc/DETAILS#format-of-the-status-fd-output)
  for a full list and description of statuses and their arguments.

  ## Options

    * `:keystore` - a `GPGex.Keystore` struct.

  ## Examples

      iex> {:ok, {messages, stdout}} = GPGex.cmd(["--recv-keys", "18D5DCA13E5D61587F552A1BDEB5A837B34DD01D"])
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
      {:ok, {[], []}}

      iex> GPGex.cmd(["--recv-keys", "91C8AFC4674BF0963E7A90CEB7FFBE9D2DF23D67"])
      {:error, {
        ["FAILURE recv-keys 167772218"],
        ["keyserver receive failed: No data"],
        ["--homedir", "/tmp/gpg_ex_keystore", "--batch", "--status-fd=1", "--recv-keys", "91C8AFC4674BF0963E7A90CEB7FFBE9D2DF23D67"]
      }}

  """
  @spec cmd([String.t()], keyword()) ::
          {:ok, {[String.t()], [String.t()]}}
          | {:error, {[String.t()], [String.t()], [String.t()]}}
  def cmd(args, opts \\ []) when is_list(args) do
    %{keystore: keystore} = Enum.into(opts, %{keystore: nil})

    args = base_args(keystore) ++ args

    {res, code} =
      System.cmd(
        "gpg",
        args,
        into: [],
        stderr_to_stdout: true
      )

    [messages, stdout] = process_output(res)

    case code do
      0 -> {:ok, {messages, stdout}}
      _ -> {:error, {messages, stdout, args}}
    end
  end

  @doc """
  Same as `cmd/2` but raises a `RuntimeError` if the command fails.

  ## Examples

      iex> GPGex.cmd!(["--unknown-option"])
      ** (RuntimeError) GPG command 'gpg --homedir /tmp/gpg_ex_keystore --batch --status-fd=1 --unknown-option' failed with:
      invalid option "--unknown-option"

      iex> {_messages, _stdout} = GPGex.cmd!(["--recv-keys", "18D5DCA13E5D61587F552A1BDEB5A837B34DD01D"])

  """
  @spec cmd!([String.t()], keyword()) :: {[String.t()], [String.t()]}
  def cmd!(args, opts \\ []) when is_list(args) do
    case cmd(args, opts) do
      {:ok, {messages, stdout}} ->
        {messages, stdout}

      {:error, {_, stdout, args}} ->
        raise RuntimeError,
              "GPG command 'gpg #{Enum.join(args, " ")}' failed with:\n#{Enum.join(stdout, "\n")}"
    end
  end

  @doc """
  Same as `cmd/2` but returns a success boolean.

  ## Examples

      iex> GPGex.cmd?(["--unknown-option"])
      false

      iex> GPGex.cmd?(["--recv-keys", "18D5DCA13E5D61587F552A1BDEB5A837B34DD01D"])
      true

  """
  @spec cmd?([String.t()], keyword()) :: boolean
  def cmd?(args, opts \\ []) when is_list(args) do
    case cmd(args, opts) do
      {:ok, _} -> true
      {:error, _} -> false
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

  defp base_args(keystore) do
    keystore = keystore || Keystore.get_keystore_global()
    keystore_args = Keystore.get_keystore_args(keystore)

    keystore_args ++ @base_args
  end
end
