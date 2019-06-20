# OopsLogger

[![CircleCI](https://circleci.com/gh/smartrent/oops_logger.svg?style=svg)](https://circleci.com/gh/smartrent/oops_logger)
[![Hex version](https://img.shields.io/hexpm/v/oops_logger.svg "Hex version")](https://hex.pm/packages/oops_logger)

An Elixir Logger for [ramoops](https://www.kernel.org/doc/html/v4.11/admin-guide/ramoops.html) linux kernal panic logger.

Ramoops uses persistent RAM for logging so the logs can survive after a restart.

## Configuration

### Add to deps

```elixir
def deps do
  [
    {:oops_logger, "~> 0.2.0"}
  ]
end
```

### Update Config

```elixir
use Mix.Config

# Add the RingLogger backend. This removes the
# default :console backend.
config :logger, backends: [OopsLogger]
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

If you want to have your system check if there
is an oops log available, and you are using Nerves,
you can add this to your `rootfs_overlay/etc/iex.exs`
file in your firmware project:

```elixir
if OopsLogger.available_log?() do
  IO.puts("Oops! There's something in the oops log. Check with OopsLogger.dump()")
end
```

## Docs 

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/oops_logger](https://hexdocs.pm/oops_logger).

