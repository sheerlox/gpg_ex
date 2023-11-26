import Config

if config_env() == :test do
  config :gpg_ex,
    global_keystore: %{
      path: "/tmp/gpg_ex_keystore"
    }
end
