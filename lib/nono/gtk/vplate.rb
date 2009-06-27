require 'gtk2'
require 'nono/config'
require 'nono/gui/comvplate'
require 'nono/gtk/config'

module Nono
  module Gtk
    class VPlate < ::Gtk::DrawingArea
      include Nono::Gui::COMVPlate
      include Nono::Gtk::Config
      def initialize
        super
        set_events(Gdk::Event::BUTTON_PRESS_MASK)
        signal_connect("button_press_event") do |win, evt|
          button_press_event(win, evt)
        end
        signal_connect("expose_event") do |win, evt|
          expose_event(win, evt)
        end
        @plate = nil
        @colors = []
        @vcells = []
        @uc_xbars = []
        @uc_ybars = []
      end

      def button_press_event(win, evt)
        update_cell(evt.x, evt.y)
      end

      def expose_event(win, evt)
        draw_all_elements
      end

      def set_plate(plate, map_colors)
        @plate = plate
        set_map_colors(map_colors)
        reset
      end

      def str2guicolor(str)
        colormap = Gdk::Colormap.system
        gdkcol = Gdk::Color.parse(str)
        colormap.alloc_color(gdkcol, false, true)
        gdkcol
      end

      def gui_backcolor
        style.bg(state)
      end

      def gui_set_color(color)
        gc = style.fg_gc(state)
        @fg = gc.foreground
        gc.set_foreground(color)
      end

      def gui_reset_color
        gc = style.fg_gc(state)
        gc.set_foreground(@fg)
      end

      def gui_set_font
        @pl = create_pango_layout
        @pl.font_description = Pango::FontDescription.new(gtk_font)
      end

      def gui_draw_text(str, x, y, color)
        @pl.set_text(str)
        window.draw_layout(style.fg_gc(state), x, y, @pl, color, style.bg(state))
      end

      def draw_cell_xy(x, y, color)
        gc = style.fg_gc(state)
        fg = gc.foreground
        gc.set_foreground(color)
        window.draw_rectangle(gc, true, x+1, y+1, one_cell_size - 2, one_cell_size - 2)
        gc.set_foreground(fg)
      end

      def gui_set_ng_color(color)
        gui_set_color(color)
      end

      def gui_reset_ng_color
        gui_reset_color
      end

      def gui_draw_line(x1, y1, x2, y2)
        window.draw_line(style.fg_gc(state), x1, y1, x2, y2)
      end

      def draw_all_elements
        draw_game_plate
        draw_cells
        draw_all_mark
      end

      def redraw_all_elements
	window.clear_area(0, 0, window.size[0], window.size[1])
      end
    end
  end
end
