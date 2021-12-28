defmodule Grid do
  defstruct [:live_cells]

  def random_init(left, top, right, bottom, prob \\ 0.5) do
    live_cells =
      for x <- left..right, y <- top..bottom, :rand.uniform() <= prob do
        {x, y}
      end

    %Grid{live_cells: live_cells}
  end
end
