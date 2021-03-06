defmodule Conway do
  @moduledoc "Conway's Game of Life!"

  use CellAuto
  use MooreNeighbourhood

  @spec transition(atom | nil, map) :: atom | nil
  def transition(state, neighbors)

  def transition(nil, %{live: 3}), do: :live
  def transition(nil, _states), do: nil

  def transition(:live, %{live: 2}), do: :live
  def transition(:live, %{live: 3}), do: :live
  def transition(:live, _states), do: nil
end
