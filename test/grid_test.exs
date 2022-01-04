defmodule GridTest do
  use ExUnit.Case
  doctest Grid

  test "can be initialized randomly" do
    left = -2
    top = -1
    right = 3
    bottom = 4

    grid = Grid.random_init(left, top, right, bottom)

    Grid.live_positions(grid)
    |> Enum.each(fn {x, y} ->
      assert left <= x
      assert x <= right
      assert top <= y
      assert y <= bottom
    end)
  end

  test "can run an iterate of the Game of Life!" do
    grid =
      Grid.from_configuration([
        {{-1, 0}, %Cell{}},
        {{0, 0}, %Cell{}},
        {{1, 0}, %Cell{}}
      ])

    grid = Conway.tick(grid)

    assert MapSet.new(Grid.live_positions(grid)) ==
             MapSet.new([{0, -1}, {0, 0}, {0, 1}])
  end
end
