defmodule OopsLogger do
  @behaviour :gen_event

  @moduledoc """
  This is an in-memory backend for the Elixir Logger that can survive reboots.

  Install it by adding it to your `config.exs`:

  ```elixir
  use Mix.Config

  config :logger, backends: [:console, OopsLogger]

  # The defaults
  config :logger, OopsLogger,
    pmsg_path: "/dev/pmsg1",
    recovered_log_path: "/sys/fs/pstore/pmsg-ramoops-1"
  ```

  Or add manually:

  ```elixir
  iex> Logger.add_backend(OopsLogger)
  :ok
  # Configure only if the defaults don't work on your system
  iex> Logger.configure(OopsLogger, pmsg_path: "/dev/pmsg1")
  ```

  After a reboot, you can check if a log exists by calling `available_log?/0`.
  """

  @default_pmsg_log_path "/sys/fs/pstore/pmsg-ramoops-0"

  @typedoc """
  Options for configuring the backend:

  * `:pmsg_path` - Path to pmsg device (default is `/dev/pmsg0`)
  * `:recovered_log_path` - Path to recovered log files from previous boots
     (default is `/sys/fs/pstore/pmsg-ramoops-0`)

  These are either specified in the Application config (e.g., `config.exs`) like
  this:

  ```elixir
  config :logger, OopsLogger,
    pmsg_path: "/dev/pmsg1",
    recovered_log_path: "/sys/fs/pstore/pmsg-ramoops-1"
  ```

  Or configured at runtime like:

  ```elixir
  iex> Logger.configure(OopsLogger, pmsg_path: "/dev/pmsg1")
  ```
  """
  @type backend_option :: {:pmsg_path, Path.t()} | {:recovered_log_path, Path.t()}

  alias OopsLogger.Server

  @doc """
  Dump the contents of the ramoops pstore file to the console
  """
  @spec dump() :: :ok | {:error, File.posix()}
  def dump() do
    case File.read(recovered_log_path()) do
      {:ok, contents} -> IO.binwrite(contents)
      error -> error
    end
  end

  @doc """
  Read the file contents from the ramoops pstore file. This is useful if you
  want to pragmatically do something with the file contents, like post to an
  external server.
  """
  @spec read() :: {:ok, binary()} | {:error, File.posix()}
  def read() do
    File.read(recovered_log_path())
  end

  @doc """
  Check to see if there a log
  """
  @spec available_log?() :: boolean()
  def available_log?() do
    File.exists?(recovered_log_path())
  end

  @doc """
  Return the path to the recovered log

  The path won't exist if there was nothing to recover on boot.
  """
  @spec recovered_log_path() :: Path.t()
  def recovered_log_path() do
    env = Application.get_env(:logger, __MODULE__, [])
    Keyword.get(env, :recovered_log_path, @default_pmsg_log_path)
  end

  #
  # Logger backend callbacks
  #
  @impl true
  def init(__MODULE__) do
    init({__MODULE__, []})
  end

  @spec init({module(), list()}) :: {:ok, term()} | {:error, term()}
  def init({__MODULE__, opts}) when is_list(opts) do
    env = Application.get_env(:logger, __MODULE__, [])
    opts = Keyword.merge(env, opts)
    Application.put_env(:logger, __MODULE__, opts)

    case Server.start_link(opts) do
      {:ok, pid} ->
        {:ok, pid}

      error ->
        error
    end
  end

  @impl true
  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    # Ignore per Elixir Logger documentation
    {:ok, state}
  end

  @impl true
  def handle_event({level, _gl, message}, state) do
    Server.log(state, level, message)
    {:ok, state}
  end

  @impl true
  def handle_event(:flush, state) do
    # No flushing needed for OopsLogger
    {:ok, state}
  end

  @impl true
  def handle_call({:configure, opts}, state) do
    {:ok, Server.configure(state, opts), state}
  end

  @impl true
  def handle_call(_request, state) do
    # Ignore to avoid crashing on bad messages
    {:ok, {:error, :unimplemented}, state}
  end

  @impl true
  def terminate(_reason, state) do
    Server.stop(state)
  end
end
