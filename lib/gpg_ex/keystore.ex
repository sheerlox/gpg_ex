defmodule GPGex.Keystore do
  @moduledoc """
  Functions for managing GPG keystores.
  """
  alias GPGex.Keystore

  @typedoc """
  An abstraction on top of GPG's `homedir` and `keyring`
  to hold references to private and public keys locations.
  """
  @type t() :: %__MODULE__{
          path: String.t(),
          keyring: String.t() | nil
        }
  @enforce_keys [:path]
  defstruct [:path, keyring: nil]

  @doc """
  Ensures the specified GPG keystore is initialized and
  returns a struct to use with `GPGex` functions.

  ## Options

    * `:path` - the GPG homedir to use, defaults to `$GNUPGHOME || "~/.gnupg"`
    * `:keyring` - the keyring filename, defaults to `nil` (uses GPG's default)

  ## Examples

    Get the default keystore:

      iex> GPGex.Keystore.get_keystore()

    Get (and maybe create) a keystore in a specific location:

      iex> keystore = GPGex.Keystore.get_keystore(path: "/tmp/test_keystore", keyring: "pubring_2.kbx")
      %GPGex.Keystore{path: "/tmp/test_keystore", keyring: "pubring_2.kbx"}
      iex> {:ok, {_, _}} = GPGex.cmd(
      ...>    ["--recv-keys", "18D5DCA13E5D61587F552A1BDEB5A837B34DD01D"],
      ...>    keystore: keystore
      ...>  )

  """
  @spec get_keystore(keyword) :: t
  def get_keystore(opts \\ []) when is_list(opts) do
    keystore = %{path: path, keyring: keyring} = build_keystore(opts)

    if !File.exists?(path) or (keyring && !File.exists?(Path.join(path, keyring))) do
      File.mkdir_p!(path)
      File.chmod!("#{path}", 0o700)

      System.cmd("gpg", get_keystore_args(keystore) ++ ["--fingerprint"],
        into: [],
        stderr_to_stdout: true
      )
    end

    keystore
  end

  @doc """
  Calls `get_keystore/2` with the global keystore options from `Config`.

  Returns `nil` if the `Config` is not set.

  ## Examples

    Get the globally configured keystore:

      iex> GPGex.Keystore.get_keystore_global()
      %GPGex.Keystore{path: "/tmp/gpg_ex_keystore", keyring: nil}

  """
  @spec get_keystore_global() :: t | nil
  def get_keystore_global() do
    case Application.fetch_env(:gpg_ex, :global_keystore) do
      {:ok, global_keystore} ->
        get_keystore(
          path: global_keystore[:path],
          keyring: global_keystore[:keyring]
        )

      _ ->
        nil
    end
  end

  @doc """
  Calls `get_keystore/2` with a writable temporary directory.
  """
  @spec get_keystore_temp() :: t()
  def get_keystore_temp() do
    tmp_dir = System.tmp_dir!()
    get_keystore(path: Path.join([tmp_dir, UUID.uuid4()]))
  end

  @doc false
  @spec get_keystore_args(t | nil) :: list(String.t())
  def get_keystore_args(keystore) do
    case keystore do
      %{path: path, keyring: nil} ->
        ["--homedir", path]

      %{path: path, keyring: keyring} ->
        ["--homedir", path, "--no-default-keyring", "--keyring", keyring]

      nil ->
        []
    end
  end

  defp build_keystore(opts) do
    default_path = System.get_env("GNUPGHOME") || Path.join(System.user_home!(), ".gnupg")

    %{path: path, keyring: keyring} =
      Enum.into(Enum.reject(opts, fn opt -> is_nil(elem(opt, 1)) end), %{
        path: default_path,
        keyring: nil
      })

    %Keystore{path: Path.expand(path), keyring: keyring}
  end
end
