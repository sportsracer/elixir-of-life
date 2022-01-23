defmodule Renderer do
  @moduledoc "Render a grid onto a wxDC device context."

  @cellSize {1, 1}
  @scale 5
  @background_color {30, 30, 30, 255}

  defp set_scale(dc) do
    :wxDC.setUserScale(dc, @scale, @scale)
    size = :wxDC.getSize(dc)
    origin = {div(elem(size, 0), 2), div(elem(size, 1), 2)}
    :wxDC.setDeviceOrigin(dc, elem(origin, 0), elem(origin, 1))
    dc
  end

  defp clear(dc) do
    backgroundBrush = :wxBrush.new()
    :wxBrush.setColour(backgroundBrush, @background_color)
    :wxDC.setBackground(dc, backgroundBrush)
    :wxDC.clear(dc)
    :wxBrush.destroy(backgroundBrush)
    dc
  end

  defp draw_cells(dc, cells) do
    cell_brush = :wxBrush.new()
    pen = :wxPen.new()
    :wxDC.setPen(dc, pen)

    # Group cells by trait – this improves drawing performance since the brush doesn't have to be
    # set so often.
    cells
    |> Enum.group_by(fn {_pos, cell} -> cell.trait end, fn {pos, _cell} -> pos end)
    |> Enum.each(fn {trait, positions} ->
      TraitBrush.adjust_brush(trait, cell_brush)
      :wxDC.setBrush(dc, cell_brush)

      positions
      |> Enum.each(fn {x, y} ->
        :wxDC.drawRectangle(dc, {x, y}, @cellSize)
      end)
    end)

    :wxPen.destroy(pen)
    :wxBrush.destroy(cell_brush)

    dc
  end

  @spec render(Grid.t(), atom) :: :ok
  def render(grid, dc) do
    dc |> set_scale() |> clear() |> draw_cells(grid.cells)
    :ok
  end
end

defprotocol TraitBrush do
  @moduledoc "Defines how a cell trait is converted to a color during drawing."

  @fallback_to_any true

  @spec adjust_brush(t, any) :: atom
  def adjust_brush(trait, brush)
end

defimpl TraitBrush, for: Any do
  @moduledoc "Default implementation which colors cells gray."

  @foreground_color {150, 150, 150, 255}

  @spec adjust_brush(any, any) :: atom
  def adjust_brush(_trait, brush), do: :wxBrush.setColour(brush, @foreground_color)
end

defimpl TraitBrush, for: Color do
  @spec adjust_brush(Color.t(), any) :: atom
  def adjust_brush(color, brush), do: :wxBrush.setColour(brush, color.r, color.g, color.b)
end
