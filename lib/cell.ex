defmodule Cell do
  @moduledoc "A live cell on a game of life grid."

  defstruct [:x, :y, trait: nil]

  @type t :: %__MODULE__{
          x: integer,
          y: integer,
          trait: Trait.t()
        }

  @spec survives?(integer) :: boolean
  def survives?(num_neighbors)

  def survives?(2), do: true
  def survives?(3), do: true
  def survives?(_), do: false

  @spec spawn_cell(Grid.pos_t(), MapSet.t(t())) :: Cell.t() | nil
  def spawn_cell({x, y}, neighbors) do
    if MapSet.size(neighbors) == 3 do
      traits = neighbors |> Enum.map(fn cell -> cell.trait end)
      crossed = Trait.cross(hd(traits), tl(traits))
      %Cell{x: x, y: y, trait: crossed}
    else
      nil
    end
  end
end

defprotocol Trait do
  @moduledoc "Genetic trait of a cell which can be crossed with another."

  @fallback_to_any true

  @spec cross(t, Enumerable.t(t)) :: t
  def cross(trait, other_traits)
end

defimpl Trait, for: Any do
  def cross(trait, _other_traits), do: trait
end
