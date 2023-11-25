defmodule GPGexTest do
  use ExUnit.Case

  setup_all do
    with {:ok, gpg_home} <- Application.fetch_env(:gpg_ex, :gpg_home) do
      if !String.starts_with?(gpg_home, "/tmp"),
        do: raise("Trying to delete '#{gpg_home}' which is outside of '/tmp'. Aborting.")

      File.rm_rf!(gpg_home)
      File.mkdir!(gpg_home)
      File.chmod!("#{gpg_home}", 0o700)

      System.shell("gpg --homedir #{gpg_home} --fingerprint",
        into: [],
        stderr_to_stdout: true
      )
    end

    :ok
  end

  doctest GPGex
end
