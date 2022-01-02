defmodule Color do
  @moduledoc "An RGB color, usable as a trait for game of life cells."

  defstruct r: 0, g: 0, b: 0

  @type c :: 0..255
  @type t :: %__MODULE__{
          r: c,
          g: c,
          b: c
        }

  @spec make(atom()) :: Color.t()
  def make(_color)

  def make(:red), do: %Color{r: 200, g: 100, b: 100}
  def make(:green), do: %Color{r: 100, g: 200, b: 100}
  def make(:blue), do: %Color{r: 100, g: 100, b: 200}
  def make(:white), do: %Color{r: 200, g: 200, b: 200}

  defimpl Trait do
    @doc "Averages all colors together."
    @spec cross(Color.t(), Enumerable.t(Color.t())) :: Color.t()
    def cross(trait, other_traits) do
      traits = Stream.concat([trait], other_traits)

      sums =
        Enum.reduce(
          traits,
          {0, 0, 0, 0},
          fn c, {rs, gs, bs, l} -> {c.r + rs, c.g + gs, c.b + bs, l + 1} end
        )

      num_traits = elem(sums, 3)

      %Color{
        r: div(elem(sums, 0), num_traits),
        g: div(elem(sums, 1), num_traits),
        b: div(elem(sums, 2), num_traits)
      }
    end
  end
end
