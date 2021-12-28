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
    assert !Cell.comes_alive?(1)
    assert !Cell.comes_alive?(2)
    assert Cell.comes_alive?(3)
    4..9 |> Enum.each(&assert !Cell.comes_alive?(&1))
  end
end
