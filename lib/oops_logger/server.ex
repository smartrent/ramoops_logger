defmodule OopsLogger.Server do
  use GenServer

  @file_name "/dev/pmsg0"

  defmodule State do
    defstruct fd: nil, format: nil
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
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

  def init(_) do
    case File.open(@file_name, [:append]) do
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

  def handle_cast({:log, level, message}, %State{fd: fd, format: format} = state) do
    output = apply_format(format, level, message)
    IO.binwrite(fd, output)
    {:noreply, state}
  end

  def terminate(_, %State{fd: fd}) do
    File.close(fd)
  end

  defp apply_format(format, level, {_, message, ts, _meta}) do
    Logger.Formatter.format(format, level, message, ts, [])
  end
end
