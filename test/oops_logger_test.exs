defmodule OopsLoggerTest do
  use ExUnit.Case, async: false

  @test_pmsg_file "__test_pmsg"

  require Logger

  setup do
    Logger.remove_backend(:console)

    # Start fresh each time
    _ = File.rm(@test_pmsg_file)
    File.touch!(@test_pmsg_file)

    # Start the OopsLogger with the test path
    Application.put_env(:logger, OopsLogger, pmsg_path: @test_pmsg_file)
    Logger.add_backend(OopsLogger, flush: true)

    on_exit(fn ->
      Logger.remove_backend(OopsLogger)
      _ = File.rm(@test_pmsg_file)
    end)

    :ok
  end

  test "logs a message" do
    _ = Logger.debug("hello")
    Logger.flush()
    Process.sleep(100)

    assert File.exists?(@test_pmsg_file)
    contents = File.read!(@test_pmsg_file)
    assert contents =~ "[debug] hello"
  end

  test "changing configuration" do
    new_path = @test_pmsg_file <> ".new"
    _ = File.rm(new_path)

    Logger.configure_backend(OopsLogger, pmsg_path: new_path)
    _ = Logger.info("changing configuration")
    Logger.flush()
    Process.sleep(100)

    contents = File.read!(new_path)
    assert contents =~ "[info]  changing configuration"

    File.rm!(new_path)
  end
end
