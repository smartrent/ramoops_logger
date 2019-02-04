defmodule OopsLogger do
  @behaviour :gen_event

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

  def init(_) do
    Server.start_link(nil)
    {:ok, nil}
  end

  def handle_call(_, _) do
    {:ok, :hello, nil}
  end

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, message}, state) do
    Server.log(level, message)
    {:ok, state}
  end

  def handle_event(:flush, state) do
    # No flushing needed for OopsLogger
    {:ok, state}
  end
end
