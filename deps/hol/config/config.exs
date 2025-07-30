import Config

config :logger,
  compile_time_purge_matching: [
    [application: :hol, level_lower_than: :notice]
  ]

import_config("#{config_env()}.exs")
