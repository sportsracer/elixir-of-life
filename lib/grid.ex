defmodule Grid do
  @moduledoc "A cellular automaton grid which extends infinitely in two dimensions."

  # Cells are indexed by position in a map, for fast retrieval of neighbours.
  @type pos_t :: {integer, integer}
  @type cell_map_t :: %{pos_t => Cell.t()}
  @type t :: %__MODULE__{
          cells: cell_map_t
        }
  defstruct cells: %{}

  @num_batches 8

  # Construction

  @spec from_configuration(Enumerable.t({pos_t, Cell.t()})) :: t
  def from_configuration(configuration), do: %Grid{cells: Map.new(configuration)}

  @spec random_init(integer, integer, integer, integer, float, atom | nil, Trait.t() | nil) :: t
  def random_init(left, top, right, bottom, density \\ 0.5, state \\ nil, trait \\ nil) do
    configuration =
      for x <- left..right, y <- top..bottom, :rand.uniform() <= density do
        {{x, y}, %Cell{state: state, trait: trait}}
      end

    Grid.from_configuration(configuration)
  end

  @spec merge(t, t) :: t
  def merge(grid, other) do
    %Grid{cells: Map.merge(grid.cells, other.cells)}
  end

  # Access

  @spec live_positions(t) :: [pos_t]
  def live_positions(grid), do: Map.keys(grid.cells)

  @spec live_cells(t) :: [Cell.t()]
  def live_cells(grid), do: Map.values(grid.cells)

  # Iteration

  # Determine which positions should be updated in the next iteration.
  @spec determine_positions_to_update(t, module) :: Enumerable.t(pos_t)
  defp determine_positions_to_update(grid, cell_auto) do
    Map.keys(grid.cells)
    |> Stream.flat_map(fn pos ->
      [pos | cell_auto.neighbourhood(pos)]
    end)
    |> MapSet.new()
  end

  # Assign positions to batches randomly, and schedule each batch for async execution.
  @spec batch_updates(t, module, Enumberable.t(pos_t)) :: [Task.t()]
  defp batch_updates(grid, cell_auto, positions) do
    positions
    |> Enum.group_by(fn _ -> Enum.random(0..@num_batches) end)
    |> Map.values()
    |> Enum.map(&Task.async(__MODULE__, :update_positions, [grid, cell_auto, &1]))
  end

  @doc "Determine the new cell (or nil) at this position in the next iteration."
  @spec update_position(t, module, pos_t) :: Cell.t() | nil
  def update_position(grid, cell_auto, pos) do
    cell = grid.cells[pos]

    # Determine frequencies of neighbours
    neighbours =
      for neighbour <- cell_auto.neighbourhood(pos),
          not is_nil(neighbour_cell = grid.cells[neighbour]) do
        neighbour_cell
      end

    neighbour_states = neighbours |> Enum.frequencies_by(fn %Cell{state: state} -> state end)

    # Return a dead, surviving or newly spawned cell
    case {cell, cell_auto.transition(cell && cell.state, neighbour_states)} do
      {_, nil} -> nil
      {nil, new_state} -> %Cell{state: new_state, trait: Cell.cross_traits(neighbours)}
      {cell = %Cell{}, new_state} -> %Cell{cell | state: new_state}
    end
  end

  @doc "Determine the new cells for multiple positions, returning results as a map."
  @spec update_positions(t, module, Enumerable.t(pos_t)) :: %{pos_t => Cell.t()}
  def update_positions(grid, cell_auto, positions) do
    for pos <- positions, not is_nil(cell = update_position(grid, cell_auto, pos)), into: %{} do
      {pos, cell}
    end
  end

  @spec tick(t, module) :: t
  def tick(grid, cell_auto) do
    positions_to_update = determine_positions_to_update(grid, cell_auto)

    batches = batch_updates(grid, cell_auto, positions_to_update)

    %Grid{
      # Merge results of all batches into one map
      cells:
        batches
        |> Enum.reduce(%{}, fn task, new_cells ->
          Map.merge(new_cells, Task.await(task))
        end)
    }
  end
end
