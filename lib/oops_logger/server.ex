defmodule OopsLogger.Server do
  use GenServer
  @moduledoc false

  @default_pmsg_path "/dev/pmsg0"

  defmodule State do
    @moduledoc false
    defstruct fd: nil, format: nil
  end

  @spec start_link([OopsLogger.server_option()]) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Update the logger configuration.

  Options include:
  * `:pmsg_path` - path to pmsg device (default is `/dev/pmsg0`)
  """
  @spec configure([OopsLogger.server_option()]) :: :ok
  def configure(opts) do
    GenServer.call(__MODULE__, {:configure, opts})
  end

  @doc """
  Log the logger message to the file
  """
  @spec log(
          Logger.level(),
          {Logger, Logger.message(), Logger.Formatter.time(), Logger.metadata()}
        ) :: :ok | {:error, :no_server}
  def log(level, message) do
    # Maybe refactor to something like
    # this: https://github.com/nerves-project/ring_logger/blob/master/lib/ring_logger/autoclient.ex#L88
    if !Process.whereis(__MODULE__) do
      {:error, :no_server}
    else
      GenServer.cast(__MODULE__, {:log, level, message})
    end
  end

  @doc """
  Stop the server
  """
  @spec stop() :: :ok
  def stop() do
    GenServer.stop(__MODULE__, :normal)
  end

  @impl true
  def init(opts) do
    opts = merge_and_update_opts(opts)

    case open_pmsg(opts) do
      {:ok, fd} ->
        state = %State{
          fd: fd,
          format: Logger.Formatter.compile(nil)
        }

        {:ok, state}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_call({:configure, opts}, _from, %State{fd: fd} = state) do
    opts = merge_and_update_opts(opts)

    _ = File.close(fd)

    case open_pmsg(opts) do
      {:ok, new_fd} ->
        new_state = %{state | fd: new_fd}

        {:reply, :ok, new_state}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_cast({:log, level, message}, %State{fd: fd, format: format} = state) do
    output = apply_format(format, level, message)
    _ = IO.binwrite(fd, output)
    {:noreply, state}
  end

  @impl true
  def terminate(_, %State{fd: fd}) do
    File.close(fd)
  end

  defp merge_and_update_opts(opts) do
    env = Application.get_env(:logger, OopsLogger, [])
    opts = Keyword.merge(env, opts)
    Application.put_env(:logger, OopsLogger, opts)
    opts
  end

  defp open_pmsg(opts) do
    path = Keyword.get(opts, :pmsg_path, @default_pmsg_path)

    File.open(path, [:append])
  end

  defp apply_format(format, level, {_, message, ts, _meta}) do
    Logger.Formatter.format(format, level, message, ts, [])
  end
end
