defmodule Conway.Patterns do
  @moduledoc "Create known game of life patterns."

  @patterns %{
    block: [
      {0, 0},
      {0, 1},
      {1, 0},
      {1, 1}
    ],
    glider: [
      {1, 0},
      {2, 1},
      {0, 2},
      {1, 2},
      {2, 2}
    ]
  }

  @spec make(atom, integer, integer, Trait.t() | nil) :: Grid.t()
  def make(pattern, left, top, trait \\ nil) do
    @patterns[pattern]
    |> offset(left, top)
    |> Stream.map(fn pos -> {pos, %Cell{trait: trait}} end)
    |> Grid.from_configuration()
  end

  defp offset(positions, left, top) when is_nil(positions) == false do
    for pos <- positions do
      {elem(pos, 0) + left, elem(pos, 1) + top}
    end
  end
end
