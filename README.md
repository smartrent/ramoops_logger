# OopsLogger

An Elixir Logger for [ramoops](https://www.kernel.org/doc/html/v4.11/admin-guide/ramoops.html) linux kernal panic logger.

Ramoops uses persistent RAM for logging so the logs can survive after a restart.

## Configuration

### Add to deps

```elixir
def deps do
  [
    {:oops_logger, "~> 0.1.0"}
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

To read the last ramoops log run:

```elixir
iex> OopsLogger.read()
```

## Docs 

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/oops_logger](https://hexdocs.pm/oops_logger).

