import Config

# Configure the main application
config :logic_visualizer,
  output_dir: "./output",
  max_depth: 100,
  debug: false,
  default_visualization: :tree

# Configure logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure escript build for CLI
config :logic_visualizer, :escript,
  main_module: LogicVisualizer.CLI.Main,
  name: "logic_visualizer",
  comment: "Logic Visualizer - A comprehensive tool for parsing and visualizing logical expressions"

# Configure dependencies
config :nimble_parsec, :doc, false

# Configure test environment
if config_env() == :test do
  config :logger, level: :warn
  config :logic_visualizer, debug: true
end

# Configure dev environment
if config_env() == :dev do
  config :logger, level: :debug
  config :logic_visualizer, debug: true
end

# Configure prod environment
if config_env() == :prod do
  config :logger, level: :info
  config :logic_visualizer, debug: false
end