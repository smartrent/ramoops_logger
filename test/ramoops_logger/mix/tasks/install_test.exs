defmodule RamoopsLogger.InstallTest do
  use ExUnit.Case, async: true
  import Igniter.Test

  require Logger

  setup do
    Logger.add_backend(RamoopsLogger, flush: true)

    :ok
  end

  test "installer adds ramoops_logger to existing target.exs" do
    test_project(
      files: %{
        "config/config.exs" => """
        import Config
        config :logger, level: :info
        config :other_thing, foo: :bar
        """
      }
    )
    |> Igniter.compose_task("ramoops_logger.install", [])
    |> assert_has_patch("config/config.exs", ~S"""
     1 1   |import Config
     2   - |config :logger, level: :info
       2 + |config :logger, level: :info, backends: [RamoopsLogger, :console]
     3 3   |config :other_thing, foo: :bar
       4 + |import_config "#{config_env()}.exs"
    """)
  end

  test "installer adds ramoops_logger to logger backends for target.exs" do
    test_project()
    |> Igniter.compose_task("ramoops_logger.install", [])
    |> assert_creates("config/config.exs", ~S"""
    import Config
    config :logger, backends: [RamoopsLogger, :console]
    import_config "#{config_env()}.exs"
    """)
  end

  test "installer adds ramoops_logger to logger backends for target.exs if present" do
    test_project(
      files: %{
        "config/target.exs" => """
        import Config
        config :logger, level: :info
        config :other_thing, foo: :bar
        """
      }
    )
    |> Igniter.compose_task("ramoops_logger.install", [])
    |> assert_has_patch("config/target.exs", ~S"""
     1 1   |import Config
     2   - |config :logger, level: :info
       2 + |config :logger, level: :info, backends: [RamoopsLogger, :console]
     3 3   |config :other_thing, foo: :bar
     4 4   |
    """)
  end
end
