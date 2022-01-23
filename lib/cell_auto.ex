defmodule CellAuto do
  @moduledoc "Abstract implementation of a cellular automaton, which depends on a concrete
  definition of a neighbourhood function and transition rules."

  @spec __using__(list | nil) :: tuple
  defmacro __using__(_opts) do
    quote do
      @behaviour CellAuto

      @spec tick(Grid.t()) :: Grid.t()
      def tick(grid) do
        Grid.tick(grid, __MODULE__)
      end
    end
  end

  @callback neighbourhood(pos :: Grid.pos_t()) :: Enumerable.t(Grid.pos_t())
  @callback transition(state :: atom, neighbours :: %{atom => non_neg_integer}) :: atom
end
