defmodule Grid do
  @moduledoc "A game of life grid which extends infinitely to all dimensions."

  defstruct live_cells: %{}

  @type pos_t :: {integer, integer}
  @type cells_t :: %{pos_t() => Cell.t()}
  @type t :: %__MODULE__{
          live_cells: cells_t()
        }

  @spec from_seed([Cell.t()]) :: t()
  def from_seed(seed), do: %Grid{live_cells: seed |> Stream.map(&index/1) |> Map.new()}

  @spec random_init(integer, integer, integer, integer, float) :: t()
  def random_init(left, top, right, bottom, prob \\ 0.5) do
    seed =
      for x <- left..right, y <- top..bottom, :rand.uniform() <= prob do
        color =
          if x < 0 do
            %Color{r: 255, g: 100, b: 100}
          else
            %Color{r: 100, g: 255, b: 100}
          end

        %Cell{x: x, y: y, trait: color}
      end

    Grid.from_seed(seed)
  end

  defp index(cell), do: {{cell.x, cell.y}, cell}

  @spec all_cells(t()) :: [t()]
  def all_cells(grid), do: Map.values(grid.live_cells)

  @spec at(t(), pos_t()) :: Cell.t() | nil
  def at(grid, {x, y}), do: grid.live_cells[{x, y}]

  defp adjacent_positions({x, y}) do
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

  @spec neighbors_of(t(), pos_t()) :: MapSet.t(Cell.t())
  def neighbors_of(grid, {x, y}) do
    {x, y}
    |> adjacent_positions()
    |> Stream.map(&Map.get(grid.live_cells, &1))
    |> Stream.reject(&is_nil/1)
    |> MapSet.new()
  end

  @spec adjacent_empty_positions(t(), pos_t()) :: MapSet.t(pos_t())
  def adjacent_empty_positions(grid, {x, y}) do
    {x, y}
    |> adjacent_positions()
    |> Stream.reject(&Map.has_key?(grid.live_cells, &1))
    |> MapSet.new()
  end

  @spec surviving_cells(Grid.t()) :: cells_t()
  def surviving_cells(grid) do
    grid.live_cells
    |> Map.filter(fn {pos, _cell} ->
      neighbors = Grid.neighbors_of(grid, pos)
      Cell.survives?(MapSet.size(neighbors))
    end)
  end

  @spec born_cells(Grid.t()) :: cells_t()
  def born_cells(grid) do
    all_adjacent_empty_cells =
      Map.keys(grid.live_cells)
      |> Stream.flat_map(fn pos -> adjacent_empty_positions(grid, pos) end)
      |> Stream.uniq()

    all_adjacent_empty_cells
    |> Stream.map(fn pos ->
      neighbors = Grid.neighbors_of(grid, pos)
      Cell.spawn_cell(pos, neighbors)
    end)
    |> Stream.reject(&is_nil/1)
    |> Map.new(&index/1)
  end

  def tick(grid) do
    surviving_cells = Task.async(Grid, :surviving_cells, [grid])
    born_cells = Task.async(Grid, :born_cells, [grid])
    %Grid{live_cells: Map.merge(Task.await(surviving_cells), Task.await(born_cells))}
  end
end
