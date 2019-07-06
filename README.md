# OopsLogger

[![CircleCI](https://circleci.com/gh/smartrent/oops_logger.svg?style=svg)](https://circleci.com/gh/smartrent/oops_logger)
[![Hex version](https://img.shields.io/hexpm/v/oops_logger.svg "Hex version")](https://hex.pm/packages/oops_logger)

An Elixir Logger for
[ramoops](https://www.kernel.org/doc/html/v4.19/admin-guide/ramoops.html) linux
kernel panic logger.

Ramoops uses persistent RAM for logging so the logs can survive after a restart.

## Configuration

OopsLogger uses the Linux `pstore` device driver, so it only works on
Linux-based platforms. The official Nerves Projects systems start the `pstore`
driver automatically and you can skip the Linux configuration.

### Linux configuration

The most important part of using the OopsLogger is ensuring that the `pstore`
device driver is enabled and configured in your Linux kernel. The device driver
writes logs to a fixed location in DRAM that is platform-specific. If you are
lucky, someone will have determined a good place to store the logs. The official
Nerves Project systems all have a small amount of memory allocated for use by
the `pstore` driver. If you are not using Nerves, it's possible that one of the
device tree files (for ARM platforms) may be helpful.

One way of testing whether the `pstore` driver is available is to check whether
the `/dev/pmsg0` file exists.

### Update your Elixir project

Once you're satisfied with the Linux, add `oops_logger` to your project's
`mix.exs` dependencies list.

```elixir
def deps do
  [
    {:oops_logger, "~> 0.2.0"}
  ]
end
```

Next, update your `config.exs` to tell the Elixir Logger to send log messages to
the `OopsLogger`:

```elixir
use Mix.Config

# Add the OopsLogger backend. If you  already have a logger configuration, add
# OopsLogger the only change needed it to add OopsLogger to the :backends list.
config :logger, backends: [OopsLogger, :console]
```

## IEx Session Usage

To read the last ramoops log to the console run:

```elixir
iex> OopsLogger.dump()
```

To read the last ramoops log and it to a variable run:

```elixir
iex> {:ok, contents} <- OopsLogger.read()
```

## Nerves Automatic Log Check

If you want to have your system check if there is an oops log available, and you
are using Nerves, you can add this to your `rootfs_overlay/etc/iex.exs` file in
your firmware project:

```elixir
if OopsLogger.available_log?() do
  IO.puts("Oops! There's something in the oops log. Check with OopsLogger.dump()")
end
```
