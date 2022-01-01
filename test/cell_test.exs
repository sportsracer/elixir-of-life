defmodule CellTest do
  use ExUnit.Case
  doctest Cell

  test "survives if it has 2 or 3 neighbors" do
    assert !Cell.survives?(1)
    assert Cell.survives?(2)
    assert Cell.survives?(3)
    4..9 |> Enum.each(&assert !Cell.survives?(&1))
  end

  test "comes alive if it has 3 neighbors" do
    one_neighbor = MapSet.new([%Cell{x: 0, y: 0}])
    assert is_nil(Cell.spawn_cell({1, 1}, one_neighbor))

    three_neighbors =
      one_neighbor |> MapSet.put(%Cell{x: 1, y: 0}) |> MapSet.put(%Cell{x: 2, y: 0})

    assert %Cell{x: 1, y: 1} = Cell.spawn_cell({1, 1}, three_neighbors)
  end
end
