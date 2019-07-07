defmodule OopsLogger.Server do
  use GenServer
  @moduledoc false

  @default_pmsg_path "/dev/pmsg0"

  defmodule State do
    @moduledoc false
    defstruct fd: nil, format: nil
  end

  @spec start_link([OopsLogger.backend_option()]) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @doc """
  Update the logger configuration.

  Options include:
  * `:pmsg_path` - path to pmsg device (default is `/dev/pmsg0`)
  """
  @spec configure(GenServer.server(), [OopsLogger.backend_option()]) :: :ok
  def configure(server, opts) do
    GenServer.call(server, {:configure, opts})
  end

  @doc """
  Log the logger message to the file
  """
  @spec log(
          GenServer.server(),
          Logger.level(),
          {Logger, Logger.message(), Logger.Formatter.time(), Logger.metadata()}
        ) :: :ok
  def log(server, level, message) do
    GenServer.cast(server, {:log, level, message})
  end

  @doc """
  Stop the server
  """
  @spec stop(GenServer.server()) :: :ok
  def stop(server) do
    GenServer.stop(server, :normal)
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

    case File.open(path, [:append]) do
      {:ok, fd} ->
        {:ok, fd}

      {:error, reason} ->
        {:error, "Unable to open '#{path}' (#{inspect(reason)}). OopsLogger won't work."}
    end
  end

  defp apply_format(format, level, {_, message, ts, _meta}) do
    Logger.Formatter.format(format, level, message, ts, [])
  end
end
