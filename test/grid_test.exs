defmodule GridTest do
  use ExUnit.Case
  doctest Grid

  test "can retrieve cells by coordinate" do
    cell = %Cell{x: 1, y: 2}
    grid = Grid.from_cells([cell])

    assert Grid.at(grid, {1, 2}) == cell
    assert Grid.at(grid, {1, 1}) == nil
  end

  test "can retrieve neighbor cells" do
    cell1 = %Cell{x: 2, y: 3}
    cell2 = %Cell{x: -1, y: 6}
    grid = Grid.from_cells([cell1, cell2])

    assert Grid.neighbors_of(grid, {1, 2}) == MapSet.new([cell1])
  end

  test "can retrieve empty adjacent cells" do
    cell1 = %Cell{x: 2, y: 3}
    cell2 = %Cell{x: -1, y: 6}
    grid = Grid.from_cells([cell1, cell2])

    assert Grid.adjacent_empty_positions(grid, {1, 2}) ==
             MapSet.new([
               {0, 1},
               {1, 1},
               {2, 1},
               {0, 2},
               {2, 2},
               {0, 3},
               {1, 3}
             ])
  end

  test "can be initialized randomly" do
    left = -2
    top = -1
    right = 3
    bottom = 4

    grid = Grid.random_init(left, top, right, bottom)

    Grid.all_cells(grid)
    |> Enum.each(fn cell ->
      assert left <= cell.x
      assert cell.x <= right
      assert top <= cell.y
      assert cell.y <= bottom
    end)
  end

  test "can run an iterate of the Game of Life!" do
    grid =
      Grid.from_cells([
        %Cell{x: -1, y: 0},
        %Cell{x: 0, y: 0},
        %Cell{x: 1, y: 0}
      ])

    grid = Grid.tick(grid)

    cells = Grid.all_cells(grid) |> MapSet.new()

    assert cells ==
             MapSet.new([
               %Cell{x: 0, y: -1},
               %Cell{x: 0, y: 0},
               %Cell{x: 0, y: 1}
             ])
  end
end
