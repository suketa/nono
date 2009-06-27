require 'nono/out'
require 'nono/gui/config'
module Nono
  module Gui
    module COMVPlate
      include Nono::Out
      include Nono::Gui::Config

      def create_pure_cells(val) 
        cells = []
        @plate.width.times do |y|
          ary = []
          @plate.height.times do |x|
            ary.push(val)
          end
          cells.push(ary)
        end
        cells
      end

      def create_vcells
        @vcells = create_pure_cells(-1)
      end

      def ybgn
        margin + yhint_max_size * one_cell_size
      end

      def xbgn
        margin + xhint_max_size * one_cell_size
      end

      def yend
        ybgn + @plate.height * one_cell_size
      end

      def xend
        xbgn + @plate.width * one_cell_size
      end

      def index2xpixel(i)
        xbgn + i * one_cell_size
      end

      def index2ypixel(j)
        ybgn + j * one_cell_size
      end

      def set_map_colors(map_colors)
        colors = map_colors
        if map_colors.empty?
          colors = [Nono::Config::DEFAULT_COLOR_CSS]
        end
        @colors = []
        colors.each do |color|
          if /\s*(\S+)\s*=\s*(\S+)\s*/ =~ color
            c = $1
            col = $2
            guicol = str2guicolor(col)
            @colors.push [c, guicol]
          end
        end
        guicol = str2guicolor("#FFFFFF")
        @colors.push [Nono::Config::BLANK, guicol]
        @colors.push ['?', gui_backcolor]
      end

      def char2color(c)
        color = @colors.find {|col|
          col[0] == c
        }
        if color
          color[1]
        else
          nil
        end
      end

      def vcells2cells
        mcells = @plate.create_initial_cells
        m = 0
        @plate.height.times do |j|
          @plate.width.times do |i|
            col = @colors[@vcells[i][j]]
            if col[0] != '?'
              mcells[m].set_color(col[0])
            end
            m += 1
          end
        end
        mcells
      end

      def bars2vcells(bars)
        bars.each_with_index do |bar, j|
          bar.cells.each_with_index do |cell, i|
            @vcells[i][j] = cell2vcolor_index(cell)
          end
        end
      end

      def cell2vcolor_index(cell)
        if cell.color
          mcolor2vcolor_index(cell.color)
        else
          mcolor2vcolor_index('?')
        end
      end

      def mcolor2vcolor_index(c)
        retval = -1
        @colors.each_with_index do |col, i|
          if col[0] == c
            retval = i
            break
          end
        end
        retval
      end

      def draw_all_mark
        gui_set_ng_color(ng_color)
        mark_unconsist_xbar(@uc_xbars)
        mark_unconsist_ybar(@uc_ybars)
        gui_reset_ng_color
      end

      def ng_color
        str2guicolor("#FF0000")
      end

      def clear_all_mark
        @uc_xbars = []
        @uc_ybars = []
        gui_set_ng_color(gui_backcolor)
        @plate.height.times do |i|
          draw_xmark(i)
        end
        @plate.width.times do |i|
          draw_ymark(i)
        end
        gui_reset_ng_color
      end

      def mark_unconsist_xbar(xbars)
        xbars.each do |i|
          draw_xmark(i)
        end
      end

      def draw_xmark(i)
        yb = index2ypixel(i) + ng_mark_offset
        draw_ng_mark(ng_mark_bgn, yb)
      end

      def mark_unconsist_ybar(bars)
        bars.each do |i|
          draw_ymark(i)
        end
      end

      def draw_ymark(i)
        xb = index2xpixel(i) + ng_mark_offset
        draw_ng_mark(xb, ng_mark_bgn)
      end

      def draw_ng_mark(xb, yb)
        xe = xb + ng_mark_size
        ye = yb + ng_mark_size
        gui_draw_line(xb, yb, xe, ye)
        gui_draw_line(xb, ye, xe, yb)
      end

      # This method is for fnono
      def gui_end
      end

      def draw_xhint
        if @plate
          gui_set_font
          xhint_size = xhint_max_size
          @plate.xhints.each_with_index do |hint, i|
            y = index2ypixel(i) + 1
            keys = hint.keys
            keys.each_with_index do |key, j|
              x = margin + (xhint_size - keys.size + j) * one_cell_size
              gui_draw_text(sprintf("%2s", key.length.to_s), x, y, char2color(key.color))
            end
          end
          gui_end
        end
      end

      def draw_yhint
        if @plate
          gui_set_font
          yhint_size = yhint_max_size
          @plate.yhints.each_with_index do |hint, i|
            x = index2xpixel(i) + 1
            keys = hint.keys
            keys.each_with_index do |key, j|
              y = margin + (yhint_size - keys.size + j) * one_cell_size
              gui_draw_text(sprintf("%2s", key.length.to_s), x, y, char2color(key.color))
            end
          end
          gui_end
        end
      end

      def draw_yline
        if @plate
          gui_set_color(str2guicolor("#000000"))
          last = yend
          (@plate.width + 1).times do |i|
            x = index2xpixel(i)
            gui_draw_line(x, margin, x, last)
          end
          gui_reset_color
        end
      end

      def draw_xline
        if @plate
          gui_set_color(str2guicolor("#000000"))
          last = xend
          (@plate.height + 1).times do |i|
            y = index2ypixel(i)
            gui_draw_line(margin, y, last, y)
          end
          gui_reset_color
        end
      end

      def xpixel2index(x)
        i = (x - xbgn) / one_cell_size
        i.truncate
      end

      def ypixel2index(y)
        j = (y - ybgn) / one_cell_size
        j.truncate
      end

      def update_cell(x, y)
        if xbgn < x && x < xend && ybgn < y && y < yend
          i = xpixel2index(x)
          j = ypixel2index(y)
          @vcells[i][j] += 1
          @vcells[i][j] %= @colors.size
          draw_cell(i, j)
        end
      end

      def draw_cells
        @vcells.each_with_index do |cells, i|
          x = index2xpixel(i)
          cells.each_with_index do |cell, j|
            y = index2ypixel(j)
            draw_cell_xy(x, y, @colors[cell][1])
          end
        end
      end

      def draw_cell(i, j)
        x = index2xpixel(i)
        y = index2ypixel(j)
        cell = @vcells[i][j]
        draw_cell_xy(x, y, @colors[cell][1])
      end

      def check_answer
        clear_all_mark
        answer = true
        cells = vcells2cells
        xbars, ybars = @plate.unconsist_bars_index(cells)
        if xbars.size > 0 || ybars.size > 0
          @uc_xbars = xbars
          @uc_ybars = ybars
          draw_all_mark
          answer = false
        end
        answer
      end

      def display_answer
        reset
        @plate.solve
        display(@plate.ansbars)
        @plate.solved?
      end

      def solve_step_by_step
        reset
        @plate.solve_from_beginning(self)
        display(@plate.ansbars)
        @plate.solved?
      end

      def display(ansbars, msg="", step=nil)
        bars2vcells(ansbars)
        draw_cells
      end

      def reset
        clear_all_mark
        create_vcells
        draw_cells
      end

      def draw_game_plate
        draw_yline
        draw_xline
        draw_xhint
        draw_yhint
      end

    end
  end
end
