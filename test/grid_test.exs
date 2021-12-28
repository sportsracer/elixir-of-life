defmodule GridTest do
  use ExUnit.Case
  doctest Grid

  test "can be initialized randomly" do
    left = -2
    top = -1
    right = 3
    bottom = 4

    grid = Grid.random_init(left, top, right, bottom)

    grid.live_cells
    |> Stream.map(fn cell ->
      x = elem(cell, 0)
      y = elem(cell, 1)
      assert left <= x
      assert x <= right
      assert top <= y
      assert y <= bottom
    end)
    |> Stream.run()
  end
end
