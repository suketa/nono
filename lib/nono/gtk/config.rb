module Nono
  module Gtk
    module Config
      FONT="Sans 10"
      def set_gtk_font(font)
        @gtk_font = font
      end

      def gtk_font
        if !@gtk_font
	  @gtk_font = FONT
	end
	@gtk_font
      end
    end
  end
end
