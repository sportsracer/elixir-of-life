defmodule PatternsTest do
  use ExUnit.Case
  doctest Grid.Patterns

  test "constructs a square still life" do
    white = Color.make(:white)
    grid = Grid.Patterns.make(:block, 0, 0, white)

    positions = Grid.all_cells(grid) |> MapSet.new(fn cell -> {cell.x, cell.y} end)
    assert positions == MapSet.new([{0, 0}, {1, 0}, {0, 1}, {1, 1}])

    Grid.all_cells(grid) |> Enum.each(fn cell -> assert cell.trait == white end)
  end
end
