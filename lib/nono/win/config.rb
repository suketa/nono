module Nono
  module Win
    module Config
      FONTNAME = "Sans"
      FONTSIZE = 16

      def win_fontname
        if !@win_fontname
          @win_fontname = FONTNAME
        end
        @win_fontname
      end

      def win_fontsize
        if !@win_fontsize
          @win_fontsize = FONTSIZE
        end
        @win_fontsize
      end

      def set_win_font(fname, fsize)
        @win_fontname = fname
        @win_fontsize = fsize
      end

    end
  end
end
