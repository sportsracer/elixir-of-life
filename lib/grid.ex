defmodule Grid do
  defstruct [:live_cells]

  @type t :: %__MODULE__{
          live_cells: %{{integer, integer} => Cell.t()}
        }

  @type pos_t :: {integer, integer}

  @neighbor_offsets MapSet.new([
                      {-1, -1},
                      {0, -1},
                      {1, -1},
                      {-1, 0},
                      {1, 0},
                      {-1, 1},
                      {0, 1},
                      {1, 1}
                    ])

  @spec from_cells([Cell.t()]) :: t()
  def from_cells(cells) do
    live_cells = for cell <- cells, into: %{}, do: {{cell.x, cell.y}, cell}
    %Grid{live_cells: live_cells}
  end

  @spec random_init(integer, integer, integer, integer, float) :: t()
  def random_init(left, top, right, bottom, prob \\ 0.5) do
    live_cells =
      for x <- left..right, y <- top..bottom, :rand.uniform() <= prob, into: %{} do
        {{x, y}, %Cell{x: x, y: y}}
      end

    %Grid{live_cells: live_cells}
  end

  @spec all_cells(t()) :: [t()]
  def all_cells(grid), do: Map.values(grid.live_cells)

  @spec at(t(), pos_t()) :: Cell.t() | nil
  def at(grid, {x, y}), do: grid.live_cells[{x, y}]

  defp adjacent_positions({x, y}) do
    for {dx, dy} <- @neighbor_offsets, into: MapSet.new() do
      {x + dx, y + dy}
    end
  end

  @spec neighbors_of(t(), pos_t()) :: MapSet.t(Cell.t())
  def neighbors_of(grid, {x, y}) do
    {x, y}
    |> adjacent_positions()
    |> Stream.map(&at(grid, &1))
    |> Stream.reject(&is_nil/1)
    |> MapSet.new()
  end

  @spec adjacent_empty_positions(t(), pos_t()) :: MapSet.t(pos_t())
  def adjacent_empty_positions(grid, {x, y}) do
    {x, y}
    |> adjacent_positions()
    |> Stream.filter(&is_nil(at(grid, &1)))
    |> MapSet.new()
  end

  @spec tick(Grid.t()) :: Grid.t()
  def tick(grid) do
    surviving_cells =
      all_cells(grid)
      |> Stream.filter(fn cell ->
        neighbors = Grid.neighbors_of(grid, {cell.x, cell.y})
        Cell.survives?(MapSet.size(neighbors))
      end)
      |> MapSet.new()

    all_adjacent_empty_cells =
      all_cells(grid)
      |> Stream.flat_map(fn cell -> adjacent_empty_positions(grid, {cell.x, cell.y}) end)
      |> Stream.uniq()

    born_cells =
      all_adjacent_empty_cells
      |> Stream.filter(fn {x, y} ->
        neighbors = Grid.neighbors_of(grid, {x, y})
        Cell.comes_alive?(MapSet.size(neighbors))
      end)
      |> Stream.map(fn {x, y} -> %Cell{x: x, y: y} end)
      |> MapSet.new()

    new_cells = MapSet.union(surviving_cells, born_cells)

    from_cells(new_cells |> Enum.to_list())
  end
end
