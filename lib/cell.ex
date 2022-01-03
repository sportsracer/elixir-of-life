defmodule Cell do
  @moduledoc "A live cell on a game of life grid."

  @type t :: %__MODULE__{
          state: atom,
          trait: Trait.t()
        }
  defstruct state: :live, trait: nil

  @spec cross_traits(Enumerable.t(Cell.t())) :: Trait.t()
  def cross_traits(cells) do
    [trait | other_traits] = cells |> Enum.map(fn cell -> cell.trait end)
    Trait.cross(trait, other_traits)
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
