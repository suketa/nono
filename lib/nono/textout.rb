require 'nono/out'
module Nono
  class TextOut
    include Out
    def initialize(file, plate)
      @file = file
      @plate = plate
      @yhint_strs = create_yhint_strs
      @xhint_strs = create_xhint_strs
    end

    def display_yhint
      puts @yhint_strs
    end

    def to_color_for_display(cell)
      if cell.fixed?
        if cell.color.length == 1
          cell.color + cell.color
        else
          cell.color
        end
      else
        "??"
      end
    end

    def display(ansbars = @plate.ansbars, msg = nil, step = nil)
      msg = create_msg if !msg
      msg = "[STEP:#{step}] " + msg if step
      puts msg
      puts ""
      xhint_size = xhint_max_size
      display_yhint
      @plate.height.times do |y|
        print(@xhint_strs[y])
        bar = ansbars[y]
        bar.cells.each do |cell|
          print to_color_for_display(cell)
        end
        puts ""
      end
      puts ""
    end

    def create_yhint_strs
      str = []
      yhint_size = yhint_max_size
      xhint_size = xhint_max_size
      buf = ""
      yhint_size.times do |i|
        buf = ""
        buf += sprintf("%#{xhint_size * 3}s    ", " ")
        @plate.width.times do |x|
          yhint = @plate.yhints[x]
          keys = yhint.keys
          if keys.size >= yhint_size - i
            j = keys.size - yhint_size + i
            buf += sprintf("%2d", keys[j].length)
          else
            buf += "  "
          end
        end
        str.push buf
      end
      str
    end

    def create_xhint_strs
      strs = []
      xhint_size = xhint_max_size
      @plate.height.times do |y|
        hint = @plate.xhints[y]
        l = hint.keys.collect {|key|
          sprintf("%2d", key.length)
        }.join(" ")
        strs.push(sprintf("%#{xhint_size * 3}s    ", l))
      end
      strs
    end

  end
end
