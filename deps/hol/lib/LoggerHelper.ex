defmodule LoggerHelper do
  @moduledoc false
  import Logger

  @type color() :: :black | :blue | :cyan | :green | :magenta | :red | :yellow | :none
  @type level() :: :debug | :info | :notice | :warning | :error | :critical | :alert | :emergency
  @type message() :: String.t() | (-> String.t())

  @spec get_color(color()) :: String.t()
  defp get_color(:red), do: IO.ANSI.red()
  defp get_color(:green), do: IO.ANSI.green()
  defp get_color(:blue), do: IO.ANSI.blue()
  defp get_color(:black), do: IO.ANSI.black()
  defp get_color(:cyan), do: IO.ANSI.cyan()
  defp get_color(:yellow), do: IO.ANSI.yellow()
  defp get_color(:magenta), do: IO.ANSI.magenta()
  defp get_color(_), do: ""

  @spec eval_message((-> String.t()) | String.t(), color()) :: String.t()
  defp eval_message(message, color) do
    case message do
      _ when is_function(message) ->
        get_color(color) <> message.()

      _ when is_binary(message) ->
        get_color(color) <> message

      _ ->
        get_color(color) <> Kernel.inspect(message)
    end
  end

  @spec log_wrapper(level(), (-> String.t()) | String.t(), color()) :: :ok
  defp log_wrapper(:debug, message, color), do: log(:debug, eval_message(message, color))
  defp log_wrapper(:info, message, color), do: log(:info, eval_message(message, color))
  defp log_wrapper(:notice, message, color), do: log(:notice, eval_message(message, color))
  defp log_wrapper(:warning, message, color), do: log(:warning, eval_message(message, color))
  defp log_wrapper(:error, message, color), do: log(:error, eval_message(message, color))
  defp log_wrapper(:critical, message, color), do: log(:critical, eval_message(message, color))
  defp log_wrapper(:alert, message, color), do: log(:alert, eval_message(message, color))
  defp log_wrapper(:emergency, message, color), do: log(:emergency, eval_message(message, color))

  @spec log_emergency(message()) :: :ok
  @spec log_emergency(message(), color()) :: :ok
  def log_emergency(message, color \\ :none) do
    log(:emergency, eval_message(message, color))
  end

  @spec log_alert(message()) :: :ok
  @spec log_alert(message(), color()) :: :ok
  def log_alert(message, color \\ :none) do
    log(:alert, eval_message(message, color))
  end

  @spec log_critical(message()) :: :ok
  @spec log_critical(message(), color()) :: :ok
  def log_critical(message, color \\ :none) do
    log(:critical, eval_message(message, color))
  end

  @spec log_error(message()) :: :ok
  @spec log_error(message(), color()) :: :ok
  def log_error(message, color \\ :none) do
    log(:error, eval_message(message, color))
  end

  @spec log_warning(message()) :: :ok
  @spec log_warning(message(), color()) :: :ok
  def log_warning(message, color \\ :none) do
    log(:warning, eval_message(message, color))
  end

  @spec log_notice(message()) :: :ok
  @spec log_notice(message(), color()) :: :ok
  def log_notice(message, color \\ :none) do
    log(:notice, eval_message(message, color))
  end

  @spec log_info(message()) :: :ok
  @spec log_info(message(), color()) :: :ok
  def log_info(message, color \\ :none) do
    log(:info, eval_message(message, color))
  end

  @spec log_debug(message()) :: :ok
  @spec log_debug(message(), color()) :: :ok
  def log_debug(message, color \\ :none) do
    log(:debug, eval_message(message, color))
  end

  @spec log_input(level(), message()) :: :ok
  def log_input(level, message) do
    log_wrapper(level, message, :green)
  end

  @spec log_output(level(), message()) :: :ok
  def log_output(level, message) do
    log_wrapper(level, message, :blue)
  end

  @spec set_logger_level(level()) :: :ok
  def set_logger_level(level) do
    Logger.configure(level: level)
  end

  @spec set_logger_debug() :: :ok
  def set_logger_debug do
    set_logger_level(:debug)
  end

  @spec set_logger_notice() :: :ok
  def set_logger_notice do
    set_logger_level(:notice)
  end

  @spec set_logger_warning() :: :ok
  def set_logger_warning do
    set_logger_level(:warning)
  end
end
