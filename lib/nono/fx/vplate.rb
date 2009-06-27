require 'nono/out'
require 'nono/gui/comvplate'
require 'nono/fx/config'

module Nono
  module Fx
    class VPlate < Fox::FXCanvas
      include Nono::Out
      include Nono::Gui::Config
      include Nono::Gui::COMVPlate

      def initialize(parent)
        super(parent, nil, 0, Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y)
        connect(Fox::SEL_PAINT) do |sender, sel, event|
          sel_paint(sender, sel, event)
        end
        connect(Fox::SEL_LEFTBUTTONRELEASE) do |sender, sel, event|
          sel_leftbuttonrelease(sender, sel, event)
        end
        @vcells = []
        @colors = []
        @uc_xbars = []
        @uc_ybars = []
      end

      def sel_paint(sender, sel, event)
        Fox::FXDCWindow.new(self, event) do |dc|
          dc.foreground = parent.backColor
          dc.fillRectangle(event.rect.x, event.rect.y, event.rect.w, event.rect.h)
        end
        draw_all_elements
      end

      def sel_leftbuttonrelease(sender, sel, event)
        update_cell(event.click_x, event.click_y)
      end

      def draw_cell_xy(x, y, color)
        Fox::FXDCWindow.new(self) do |dc|
          dc.foreground = color
          dc.fillRectangle(x+1, y+1, one_cell_size-2, one_cell_size-2)
        end
      end

      def set_plate(plate, colors)
        @plate = plate
        set_map_colors(colors)
        reset
      end

      def str2guicolor(str)
        Fox::FXRGB(str[1,2].hex, str[3,2].hex, str[5,2].hex)
      end

      def gui_backcolor
        parent.backColor
      end

      def gui_set_color(color)
        @dc = Fox::FXDCWindow.new(self)
        @dc.begin(self)
        @dc.foreground = color
      end

      def gui_reset_color
        @dc.foreground = str2guicolor("#000000")
        @dc.end
        @dc = nil
      end

      def setFont(font)
        @font = font
      end

      def gui_set_font
        @dc = Fox::FXDCWindow.new(self)
        @dc.begin(self)
        @dc.setFont(@font)
      end

      def gui_end
        @dc.end
        @dc = nil
      end

      def gui_draw_text(str, x, y, color)
        @dc.foreground = color
        @dc.drawText(x, y + one_cell_size - 3, str)
      end

      def gui_set_ng_color(color)
        @dc = Fox::FXDCWindow.new(self)
        @dc.begin(self)
        @dc.foreground = color
      end

      def gui_reset_ng_color
        @dc.foreground = str2guicolor("#000000")
        @dc.end
        @dc = nil
      end

      def gui_draw_line(x1, y1, x2, y2)
        @dc.drawLine(x1, y1, x2, y2)
      end

      def draw_all_elements
        draw_game_plate
        draw_cells
        draw_all_mark
      end

    end
  end
end
