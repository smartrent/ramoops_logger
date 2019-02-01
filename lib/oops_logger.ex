defmodule OopsLogger do
  @behaviour :gen_event

  alias OopsLogger.Server

  def read() do
    case File.read("/sys/fs/pstore/pmsg-ramoops-0") do
      {:ok, contents} -> IO.binwrite(contents)
      error -> error
    end
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
    {:ok, state}
  end
end
