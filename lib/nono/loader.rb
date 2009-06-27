module Nono
  class Loader
    attr_reader :xlines, :ylines, :css_colors
    def initialize(file)
      @xlines = []
      @ylines = []
      @css_colors = []
      load(file)
    end
    def load(file)
      lines = open(file) {|ifs|
        ifs.readlines
      }.select {|l|
        /^\s*$/ !~ l && /^#/ !~ l
      }

      data_block = nil
      lines.each do |l|
        if /vertical/i =~ l
          data_block = "vertical"
        elsif /horizon/i =~ l
          data_block = "horizon"
        elsif /color/i =~ l
          data_block = "color"
        else
          case data_block
          when "vertical"
            @ylines.push(l)
          when "horizon"
            @xlines.push(l)
          when "color"
            @css_colors.push(l.chomp)
          end
        end
      end

      if xlines.empty? || ylines.empty?
        raise NonoError, "File format error: #{file}"
      end
    end

  end
end
