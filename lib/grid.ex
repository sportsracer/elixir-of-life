defmodule Grid do
  @moduledoc "A cellular automaton grid which extends infinitely in two dimensions."

  # Cells are indexed by position in a map, for fast retrieval of neighbours.
  @type pos_t :: {integer, integer}
  @type cell_map_t :: %{pos_t() => Cell.t()}
  @type t :: %__MODULE__{
          cells: cell_map_t
        }
  defstruct cells: %{}

  # Construction

  @spec from_configuration(Enumerable.t({pos_t(), Cell.t()})) :: t()
  def from_configuration(configuration), do: %Grid{cells: Map.new(configuration)}

  @spec random_init(integer, integer, integer, integer, float, atom | nil, Trait.t() | nil) :: t()
  def random_init(left, top, right, bottom, density \\ 0.5, state \\ nil, trait \\ nil) do
    configuration =
      for x <- left..right, y <- top..bottom, :rand.uniform() <= density do
        {{x, y}, %Cell{state: state, trait: trait}}
      end

    Grid.from_configuration(configuration)
  end

  @spec merge(t(), t()) :: t()
  def merge(grid, other) do
    %Grid{cells: Map.merge(grid.cells, other.cells)}
  end

  # Access

  @spec live_positions(t()) :: [pos_t()]
  def live_positions(grid), do: Map.keys(grid.cells)

  @spec live_cells(t()) :: [Cell.t()]
  def live_cells(grid), do: Map.values(grid.cells)

  # Iteration

  @spec live_neighbours(t(), pos_t(), module) :: [Cell.t()]
  def live_neighbours(grid, pos, cell_auto) do
    cell_auto.neighbourhood(pos)
    |> Stream.map(&Map.get(grid.cells, &1))
    |> Enum.reject(&is_nil/1)
  end

  @spec state_frequencies([Cell.t()]) :: %{atom => non_neg_integer}
  def state_frequencies(cells) do
    cells
    |> Enum.frequencies_by(fn %Cell{state: state} -> state end)
  end

  @spec adjacent_empty_positions(t(), pos_t(), module) :: [pos_t()]
  def adjacent_empty_positions(grid, pos, cell_auto) do
    cell_auto.neighbourhood(pos)
    |> Enum.reject(&Map.has_key?(grid.cells, &1))
  end

  @spec surviving_cells(t(), module) :: cell_map_t()
  def surviving_cells(grid, cell_auto) do
    grid.cells
    |> Map.map(fn {pos, cell} ->
      neighbour_states = live_neighbours(grid, pos, cell_auto) |> state_frequencies()

      case cell_auto.transition(cell.state, neighbour_states) do
        nil -> nil
        new_state -> %Cell{cell | state: new_state}
      end
    end)
    |> Map.reject(fn {_key, value} -> is_nil(value) end)
  end

  @spec spawned_cells(t(), module) :: cell_map_t()
  def spawned_cells(grid, cell_auto) do
    grid.cells
    |> Map.keys()
    |> Stream.flat_map(fn pos -> adjacent_empty_positions(grid, pos, cell_auto) end)
    |> Stream.uniq()
    |> Map.new(fn pos ->
      live_neighbours = live_neighbours(grid, pos, cell_auto)
      neighbour_states = state_frequencies(live_neighbours)

      {pos,
       case cell_auto.transition(nil, neighbour_states) do
         nil -> nil
         new_state -> %Cell{state: new_state, trait: Cell.cross_traits(live_neighbours)}
       end}
    end)
    |> Map.reject(fn {_key, value} -> is_nil(value) end)
  end
end
