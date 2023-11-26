defmodule GPGexTest do
  use ExUnit.Case

  setup_all do
    global_test_keystore = GPGex.Keystore.get_keystore_global()

    on_exit(fn ->
      %{path: test_keystore_path} = global_test_keystore
      File.rm_rf!(test_keystore_path)
    end)
  end

  doctest GPGex

  # describe "GPGex" do
  #   # creates a new temporary keystore for each test and delete it on exit
  #   setup do
  #     test_keystore = GPGex.Keystore.get_keystore_temp()

  #     on_exit(fn ->
  #       %{path: test_keystore_path} = test_keystore
  #       File.rm_rf!(test_keystore_path)
  #     end)

  #     {:ok, [keystore: test_keystore]}
  #   end
  # end
end
