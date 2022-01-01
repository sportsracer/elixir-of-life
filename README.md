# Elixir of Life

Implementation of Conway's Game of Life in Elixir. Cells are colored, and when new cells are spawned, they take on the average color of their ancestors. The rules of when cells die or are spawned are unchanged, though.

## Installation

Requires Elixir and an Erlang distribution with wxWidgets bindings. On macOS, you can get all that with just `brew install elixir`.

## Usage

Simulate a randomly seeded game:

```shell
mix run
```
## Development

```shell
mix format
mix test --no-start
```