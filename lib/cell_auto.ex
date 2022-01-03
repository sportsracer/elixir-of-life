defmodule CellAuto do
  @moduledoc "Abstract implementation of a cellular automaton, which depends on a concrete
  definition of a neighbourhood function and transition rules."

  defmacro __using__(_opts) do
    quote do
      @behaviour CellAuto

      @spec tick(Grid.t()) :: Grid.t()
      def tick(grid) do
        surviving_cells = Task.async(Grid, :surviving_cells, [grid, __MODULE__])
        spawned_cells = Task.async(Grid, :spawned_cells, [grid, __MODULE__])
        %Grid{cells: Map.merge(Task.await(surviving_cells), Task.await(spawned_cells))}
      end
    end
  end

  @callback neighbourhood(pos :: Grid.pos_t()) :: Enumerable.t(Grid.pos_t())
  @callback transition(state :: atom, neighbours :: %{atom => non_neg_integer}) :: atom
end
