defmodule OopsLogger do
  @behaviour :gen_event

  @moduledoc """
  This is an in-memory backend for the Elixir Logger that can survive reboots.

  Install it by adding it to your `config.exs`:

  ```elixir
  use Mix.Config

  config :logger, backends: [:console, OopsLogger]

   ```

  Or add manually:

  ```elixir
  Logger.add_backend(OopsLogger)
  ```

  After a reboot, you can check if a log exists by calling `available_log?/0`.
  """

  @ramoops_file "/sys/fs/pstore/pmsg-ramoops-0"

  alias OopsLogger.Server

  @doc """
  Read the contents of the ramoops pstore file to the console
  """
  @spec read() :: :ok | {:error, File.posix()}
  def read() do
    case File.read(@ramoops_file) do
      {:ok, contents} -> IO.binwrite(contents)
      error -> error
    end
  end

  @doc """
  Check to see if there a log
  """
  @spec available_log?() :: boolean()
  def available_log?() do
    File.exists?(@ramoops_file)
  end

  @doc """
  Stop the OopsLogger backend
  """
  @spec stop() :: :ok
  def stop() do
    Server.stop()
  end

  @impl true
  def init(_) do
    {:ok, _pid} = Server.start_link(nil)
    {:ok, nil}
  end

  @impl true
  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end

  @impl true
  def handle_event({level, _gl, message}, state) do
    _ = Server.log(level, message)
    {:ok, state}
  end

  @impl true
  def handle_event(:flush, state) do
    # No flushing needed for OopsLogger
    {:ok, state}
  end

  @impl true
  def handle_call(_, state) do
    # Ignore to avoid crashing on bad messages
    {:ok, {:error, :unimplemented}, state}
  end

  @impl true
  def terminate(_reason, _state) do
    Server.stop()
    :ok
  end
end
