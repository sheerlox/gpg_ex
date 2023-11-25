import Config

if config_env() == :test do
  config :gpg_ex,
    gpg_home: "/tmp/gpg_ex_test_gpg_home"
end
