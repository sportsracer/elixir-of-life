defmodule PatternsTest do
  use ExUnit.Case
  doctest Conway.Patterns

  test "constructs a square still life" do
    white = Color.make(:white)
    grid = Conway.Patterns.make(:block, 0, 0, white)

    positions = MapSet.new(Grid.live_positions(grid))
    assert positions == MapSet.new([{0, 0}, {1, 0}, {0, 1}, {1, 1}])

    Grid.live_cells(grid) |> Enum.each(fn cell -> assert cell.trait == white end)
  end
end
