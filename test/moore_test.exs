defmodule MooreNeighbourhoodTest do
  use ExUnit.Case
  doctest MooreNeighbourhood

  test "retrieves a position's neighbors" do
    pos = {1, 1}

    expected =
      MapSet.new([
        {0, 0},
        {1, 0},
        {2, 0},
        {0, 1},
        {2, 1},
        {0, 2},
        {1, 2},
        {2, 2}
      ])

    assert MapSet.new(MooreNeighbourhood.neighbourhood(pos)) == expected
  end
end
