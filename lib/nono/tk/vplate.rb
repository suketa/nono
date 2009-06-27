require 'tk'
require 'nono/plate'
require 'nono/out'
require 'nono/gui/comvplate'
require 'nono/tk/config'
module Nono
  module Tk
    class VPlate < ::TkCanvas
      include Nono::Out
      include Nono::Gui::Config
      include Nono::Gui::COMVPlate
      def initialize(*args)
        super(*args)
        bind("1", proc{|e| lbutton_clicked(e.x, e.y)})
        @plate = nil
        @colors = []
        @vcells = []
        @uc_xbars = []
        @uc_ybars = []
        @lines = []
        @hints = []
        @tkcells = []
        @ng_marks = []
      end

      def lbutton_clicked(x, y)
        if @plate
          update_cell(x, y)
        end
      end

      def draw_cell_xy(x, y, color)
        i = xpixel2index(x)
        j = ypixel2index(y)
        if @tkcells[i][j]
          @tkcells[i][j].configure(:fill => color)
        else
          @tkcells[i][j] = TkcRectangle.new(self, x+1, y+1, x+one_cell_size - 1, y + one_cell_size-1, 
                                            :fill => color, :outline => bg)
        end
      end

      def set_plate(plate, map_colors)
        @plate = plate
        set_map_colors(map_colors)
        all_clear
        draw_game_plate
        reset
      end

      def str2guicolor(col)
        col
      end

      def gui_backcolor
        bg
      end

      def gui_set_color(color)
        @fgcolor = color
        @targets = @lines
      end

      def gui_reset_color
        @fgcolor = str2guicolor("#000000")
      end

      def gui_set_font
        @font = TkFont.new(Config::FONT)
      end

      def gui_draw_text(str, x, y, color)
        @hints.push TkcText.new(self, x + one_cell_size / 2, y + one_cell_size/2, 
                                :text=>str, :fill=>color, :font=>@font)
      end

      def create_vcells
        super
        @tkcells = create_pure_cells(nil)
      end

      def all_clear
        (@lines + @hints).each do |obj|
          obj.destroy
        end
        @lines = []
        @hints = []
        @tkcells.each do |tkcells|
          tkcells.each do |tkcell|
            tkcell.destroy if tkcell
            tkcell = nil
          end
        end
        @tkcells = []
      end

      def gui_set_ng_color(color)
        @fgcolor = color
        @targets = @ng_marks
      end

      def gui_reset_ng_color
        @fgcolor = str2guicolor("#000000")
        @targets = @ng_marks
      end

      def clear_all_mark
        @uc_xbars = []
        @uc_ybars = []
        @ng_marks.each do |mark|
          mark.configure(:fill => "")
          mark.destroy
        end
        @ng_marks = []
      end

      def gui_draw_line(x1, y1, x2, y2)
        @targets.push TkcLine.new(self, x1, y1, x2, y2, :fill => @fgcolor)
      end
      def display(ansbars, msg="", step=nil)
        super(ansbars, msg, step)
        ::Tk.update_idletasks
      end

    end
  end
end
