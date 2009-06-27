require 'nono/config'
module Nono
  class Cell
    attr_reader :x, :y, :colors
    def initialize(x, y, colors)
      @x = x
      @y = y
      @colors = colors.dup
    end
    def fixed?
      @colors.size == 1
    end
    def set_blank
      set_color(Config::BLANK)
    end
    def color
      if fixed?
        @colors[0]
      else
        nil
      end
    end
    def set_color(color)
      if !fixed?
        @colors = [color]
      end
    end
    def set_colors(colors)
      if !fixed?
        @colors = @colors & colors
      end
    end
    def blank?
      fixed? && @colors[0] == Config::BLANK
    end
    def colored?
      fixed? && @colors[0] != Config::BLANK
    end
    def remove_color(color)
      if !fixed?
        @colors.delete(color)
      end
    end
    def assumpt_color
      set_color(@colors[0])
    end

    def outer_from(width, height)
      r = width - @x
      u = height - @y
      [@x, @y, r, u].min
    end
  end
end
