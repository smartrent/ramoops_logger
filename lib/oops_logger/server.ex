defmodule OopsLogger.Server do
  use GenServer

  @file_name "/dev/pmsg0"

  defmodule State do
    defstruct fd: nil, format: nil
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def log(level, message) do
    GenServer.cast(__MODULE__, {:log, level, message})
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
    IO.write(fd, output) 
    {:noreply, state}
  end

  def terminate(_, %State{fd: fd}) do
    File.close(fd)
  end

  defp apply_format(format, level, {_, message, ts, meta}) do
    Logger.Formatter.format(format, level, message, ts, [])
  end
end
