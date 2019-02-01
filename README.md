# OopsLogger

An Elixir Logger for [ramoops](https://www.kernel.org/doc/html/v4.11/admin-guide/ramoops.html) linux kernal panic logger.

Ramoops uses persistent RAM for logging so the logs can survive after a restart.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `oops_logger` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:oops_logger, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/oops_logger](https://hexdocs.pm/oops_logger).

