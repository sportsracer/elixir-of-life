defmodule View do
  @cellSize {1, 1}
  @scale 10
  @background_color {30, 30, 30, 255}
  @foreground_color {255, 150, 150, 255}

  defp set_scale(dc) do
    :wxDC.setUserScale(dc, @scale, @scale)
    size = :wxDC.getSize(dc)
    origin = {div(elem(size, 0), 2), div(elem(size, 1), 2)}
    :wxDC.setDeviceOrigin(dc, elem(origin, 0), elem(origin, 1))
  end

  defp clear(dc) do
    backgroundBrush = :wxBrush.new()
    :wxBrush.setColour(backgroundBrush, @background_color)
    :wxDC.setBackground(dc, backgroundBrush)
    :wxDC.clear(dc)
    :wxBrush.destroy(backgroundBrush)
  end

  defp draw_cells(dc, cells) do
    foregroundBrush = :wxBrush.new()
    :wxBrush.setColour(foregroundBrush, @foreground_color)
    :wxDC.setBrush(dc, foregroundBrush)
    :wxDC.setPen(dc, :wxPen.new())

    cells
    |> Stream.map(fn cell ->
      :wxDC.drawRectangle(dc, {cell.x, cell.y}, @cellSize)
    end)
    |> Stream.run()

    :wxBrush.destroy(foregroundBrush)
  end

  def render(grid, dc) do
    set_scale(dc)

    clear(dc)

    draw_cells(dc, Grid.all_cells(grid))
  end
end
