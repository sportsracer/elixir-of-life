defmodule Renderer do
  @moduledoc "Render a grid onto a wxDC device context."

  @cellSize {1, 1}
  @scale 10
  @background_color {30, 30, 30, 255}

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
    cell_brush = :wxBrush.new()
    :wxDC.setPen(dc, :wxPen.new())

    cells
    |> Enum.each(fn cell ->
      TraitBrush.adjust_brush(cell.trait, cell_brush)
      :wxDC.setBrush(dc, cell_brush)
      :wxDC.drawRectangle(dc, {cell.x, cell.y}, @cellSize)
    end)

    :wxBrush.destroy(cell_brush)
  end

  def render(grid, dc) do
    set_scale(dc)

    clear(dc)

    draw_cells(dc, Grid.all_cells(grid))
  end
end

defprotocol TraitBrush do
  @moduledoc "Defines how a cell trait is converted to a color during drawing."

  @fallback_to_any true

  @spec adjust_brush(t, any) :: atom()
  def adjust_brush(trait, brush)
end

defimpl TraitBrush, for: Any do
  @moduledoc "Default implementation which colors cells gray."

  @foreground_color {150, 150, 150, 255}

  @spec adjust_brush(any, any) :: atom()
  def adjust_brush(_trait, brush), do: :wxBrush.setColour(brush, @foreground_color)
end

defimpl TraitBrush, for: Color do
  @spec adjust_brush(Color.t(), any) :: atom()
  def adjust_brush(color, brush), do: :wxBrush.setColour(brush, color.r, color.g, color.b)
end
