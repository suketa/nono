require 'vr/vruby'
require 'vr/vrcontrol'
require 'vr/vrhandler'
require 'nono/gui/comvplate'
require 'nono/win/config'
require 'nono/out'
require 'nono/config'

module Nono
  module Win

    class VPlate < VRCanvasPanel
      include Nono::Out
      include Nono::Gui::COMVPlate
      include Nono::Win::Config
      def construct
        @i = -1
        @colors = []
        @plate = nil
        @bkcolor = nil
        @canvas = nil
        @vcells = []
        @uc_xbars = []
        @uc_ybars = []
      end

      def self_paint
        set_bkcolor
        super
      end

      def easyrefresh
        dopaint {
          self_paint
        }
      end

      def set_bkcolor
        if !@bkcolor
          @bkcolor = getPixel(1,1)
        end
      end

      include VRMouseFeasible
      def self_lbuttonup(shift, x, y)
        if @plate_setting
          @plate_setting = false
        else
          if @canvas
            update_cell(x, y)
          end
          easyrefresh
        end
      end

      def draw_cell_xy(x, y, color)
        @canvas.setBrush(color)
        @canvas.setPen(@bkcolor)
        @canvas.fillRect(x+1, y+1, x + one_cell_size, y + one_cell_size)
        @canvas.setPen(RGB(0,0,0))
      end

      def set_plate(plate, colors)
        @plate_setting = true
        @plate = plate
        clear_draw_area
        set_map_colors(colors)
        reset
        draw_all_elements
        easyrefresh
      end

      def str2guicolor(col)
        RGB(col[1,2].hex, col[3,2].hex, col[5,2].hex)
      end

      def gui_backcolor
        @bkcolor
      end


      def gui_set_color(color)
        @canvas.setPen(color)
      end

      def gui_reset_color
        @canvas.setPen(str2guicolor("#000000"))
      end

      def gui_set_font
        font = @screen.factory.newfont(win_fontname, win_fontsize)
        @canvas.setFont(font)
      end

      def gui_draw_text(str, x, y, color)
        @canvas.textColor = color
        @canvas.drawText(str, x, y, x + one_cell_size - 1, y + one_cell_size - 1)
      end

      def canvas_width_from_plate
        xhint_size = xhint_max_size
        margin + one_cell_size * (xhint_size + @plate.width) + margin
      end

      def canvas_height_from_plate
        yhint_size = yhint_max_size
        margin + one_cell_size * (yhint_size + @plate.height) + margin
      end

      def display(ansbars, msg="", step=nil)
        super(ansbars, msg, step)
        easyrefresh
      end

      def check_answer
        answer = super
        easyrefresh
        answer
      end

      def gui_set_ng_color(color)
        @canvas.setPen(color)
      end

      def gui_reset_ng_color
        @canvas.setPen(str2guicolor("#000000"))
      end

      def gui_draw_line(x1, y1, x2, y2)
        @canvas.drawLine(x1, y1, x2, y2)
      end

      def reset
        super
        easyrefresh
      end

      def draw_all_elements
        draw_game_plate
      end

      def clear_draw_area
        createCanvas(canvas_width_from_plate, canvas_height_from_plate, @bkcolor)
        @canvas.opaque = false
      end

      def redraw_all_elements
        clear_draw_area
        draw_game_plate
        draw_cells
        draw_all_mark
      end

    end
  end
end
