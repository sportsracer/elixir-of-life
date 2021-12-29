defmodule Cell do
  @moduledoc "A live cell on a game of life grid."

  defstruct [:x, :y]

  @type t :: %__MODULE__{
          x: integer,
          y: integer
        }

  @spec survives?(integer) :: boolean
  def survives?(num_neighbors) do
    case num_neighbors do
      2 -> true
      3 -> true
      _ -> false
    end
  end

  @spec comes_alive?(integer) :: boolean
  def comes_alive?(num_neighbors) do
    num_neighbors == 3
  end
end
