defmodule GPGexTest.Keystore do
  use ExUnit.Case

  alias GPGex.Keystore

  doctest GPGex.Keystore

  test "initializes a new temporary keystore" do
    %{path: path} = Keystore.get_keystore_temp()
    assert File.exists?(path)
  end
end
