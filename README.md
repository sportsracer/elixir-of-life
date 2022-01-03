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

### Lint & run tests

```shell
mix format
mix test --no-start
```
### Overview of files

* [`Conway`](lib/conway.ex) contains the rules for Conway's Game of Life. Some common patterns such as blocks and gliders can be constructed from the [`Conway.Patterns`](lib/patterns.ex) module
* [`Grid`](lib/grid.ex) holds a two-dimensional grid of stateful cells. It contains code to compute an iteration of a general two-dimensional cellular automaton, as defined by a concrete implementer of [`CellAuto`](lib/cell_auto.ex)
* Grids are composed of [`Cells`](lib/cell.ex), which can have traits such as a [`Color`](lib/color.ex) which get crossed when new cells are spawned
* The [`wx_view`](lib/wx_view/) folder contains code to display a game of life in a window powered by wxWidgets
* The [`Controller`](lib/controller.ex) repeatedly iterates a game of life, and visualizes it in a view
* … whereas the [`App`](lib/app.ex) is the app entry point where the game seed gets constructed