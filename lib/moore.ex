defmodule MooreNeighbourhood do
  @moduledoc "The so-called Moore Neighbourhood is just the cells horizontally, vertically and
  diagonally adjacent on a two-dimensional grid."

  defmacro __using__(_opts) do
    quote do
      # Inject the neighbourhood function into the client class. Just importing it isn't enough
      # since that doesn't make it available to other macros.
      defdelegate neighbourhood(pos), to: MooreNeighbourhood
    end
  end

  @spec neighbourhood(pos :: CellAuto.pos_t()) :: [CellAuto.pos_t()]
  def neighbourhood({x, y}) do
    [
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x + 1, y},
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1}
    ]
  end
end
