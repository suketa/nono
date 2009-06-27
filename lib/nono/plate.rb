require 'nono/config'
require 'nono/cell'
require 'nono/bar'
require 'nono/hint'
require 'nono/key'

module Nono
  class NonoError < StandardError
  end

  class Plate
    SOLVERS = [
      :solve_by_zero_key,
      :solve_by_larger_half,
      :solve_by_fixed_nums,
      :solve_by_same_length,
      :solve_by_terminal_fixed,
      :solve_by_inner_cell_fixed,
      :solve_by_nallow_space,
      :solve_by_terminal_unreached,
      :solve_by_same_nums,
      :solve_by_one_unfixed_cell,
      :solve_by_all_non_blank_fixed,
      :solve_by_max_fixed,
      :solve_by_unreached_area,
      :solve_by_one_key_includable_colored_range,
      :solve_by_side_cell_fixed,
      :solve_by_includable_same_length_key,
      :solve_by_inner_terminal_unreached,
      :solve_by_key_range,

      :nallow_range,
    ]

    attr_reader :cells
    attr_reader :xhints, :yhints, :width, :height, :ansbars, :thinking_time

    def initialize(xlines, ylines)
      @width = ylines.size
      @height = xlines.size
      @keys = create_keys(xlines, ylines.size - 1, Config::X) +
              create_keys(ylines, xlines.size - 1, Config::Y)
      @svkeys = create_keys_for_try
      @cells = create_cells(@keys)

      @xhints, @yhints = create_hints(@svkeys)

      @ansbars = nil
      @thinking_time = 0
    end

    def create_keys(lines, to, orient)
      keys = []
      lines.each_with_index do |l, pos|
        lkeys = l.chomp.split(',')
        lkeys.each_with_index do |e, idx|
          if /\s*(\d+)\s*([^\d]+)\s*/ =~ e
            len = $1.to_i
            color = $2
          else
            len = e.to_i
            color = Config::DEFAULT_COLOR
          end
          keys.push(Key.new(len, color, 0, to, orient, pos, idx))
        end
      end
      keys
    end

    def create_cells(keys)
      colors = keys.collect {|key|
        key.color
      }.uniq!
      colors.push(Config::BLANK)
      cells = []
      @height.times do |y|
        @width.times do |x|
          cells.push(Cell.new(x, y, colors))
        end
      end
      cells
    end

    def create_cells_for_try
      cells = []
      @cells.each do |cell|
        cells.push(Cell.new(cell.x, cell.y, cell.colors))
      end
      cells
    end

    def create_initial_cells
      create_cells(@svkeys)
    end

    def create_keys_for_try
      keys = []
      @keys.each do |key|
        keys.push(key.dup)
      end
      keys
    end
      
    def create_bars(cells)
      xbars = []
      ybars = []
      @height.times do |i|
        bar = create_xbar(i, cells)
        xbars.push(bar)
      end
      @width.times do |i|
        bar = create_ybar(i, cells)
        ybars.push(bar)
      end
      [xbars, ybars]
    end

    def create_xbar(y, cells)
      xcells = cells.select {|cell|
        cell.y == y
      }
      Bar.new(xcells, "H[#{y + 1}]")
    end

    def create_ybar(x, cells)
      ycells = cells.select {|cell|
        cell.x == x
      }
      Bar.new(ycells, "V[#{x + 1}]")
    end

    def create_hints(keys)
      xhints = []
      yhints = []
      @height.times do |y|
        h = xhint(y, keys)
        h.reset_range_forced(0, @width - 1)
        xhints.push(h)
      end
      @width.times do |x|
        h = yhint(x, keys)
        h.reset_range_forced(0, @height - 1)
        yhints.push(h)
      end
      init_keys_range(xhints+yhints)
      [xhints, yhints]
    end

    def xhint(y, keys)
      xkeys = keys.select {|key|
        key.orient == Config::X && key.pos == y
      }
      Hint.new(xkeys)
    end

    def yhint(x, keys)
      ykeys = keys.select {|key|
        key.orient == Config::Y && key.pos == x
      }
      Hint.new(ykeys)
    end

    def init_keys_range(hints)
      hints.each do |h|
        h.init_range
      end
    end

    def solved?
      fixed?(@cells)
    end

    def fixed?(cells)
      cells.select {|cell|
        !cell.fixed?
      }.empty?
    end

    def fixed_nums(cells)
      cells.select {|cell|
        cell.fixed?
      }.size
    end

    def attach_hint(xbars, ybars, xhints, yhints)
      xbars.each_with_index do |bar, i|
        bar.attach_hint(xhints[i])
      end
      ybars.each_with_index do |bar, i|
        bar.attach_hint(yhints[i])
      end
    end

    def unfixed_bars(bars)
      bars.select{|bar|
        !bar.fixed?
      }
    end

    def select_cells_for_assumption(xbars, ybars)
      @cells.select{|cell|
        !cell.fixed?
      }.collect {|cell|
        xbar = xbars[cell.y]
        ybar = ybars[cell.x]
        x_size = xbar.unfixed_cell_size
        y_size = ybar.unfixed_cell_size
        if x_size > y_size
          x_size = y_size
        end
        left = xbar.first_index_unfixed_cell || 0
        right = xbar.last_index_unfixed_cell || @width - 1
        top = ybar.first_index_unfixed_cell || 0
        bottom = ybar.last_index_unfixed_cell || @height - 1
        outer = [(left - cell.x).abs, 
                 (right - cell.x).abs, 
                 (top - cell.y).abs,
                 (bottom - cell.y).abs].min
        [cell, outer, x_size] 
      }.sort {|a, b|
        if a[1] != b[1]
          a[1] <=> b[1]
        else
          a[2] <=> b[2]
        end
      }.collect {|a|
        a[0]
      }
    end

    def try_solve_one_assumption(xbs, ybs, out)
      as_cells = select_cells_for_assumption(xbs, ybs)
      as_cells.each do |as_cell|

        cells = create_cells_for_try
        cell = cells.find {|cell| cell.x == as_cell.x && cell.y == as_cell.y}
        cell.assumpt_color

        xbars, ybars = create_bars(cells)
        xhints, yhints = create_hints(@svkeys)
        attach_hint(xbars, ybars, xhints, yhints)
        (xbars + ybars).each do |bar|
          bar.nallow_range
        end
        if out
          out.display(xbars, "assert Cell[#{cell.x}, #{cell.y}] color is #{cell.color}") 
        end
        solve_no_assumption(xbars, ybars, cells, out)
        uc_bars = (xbars + ybars).select {|bar|
          !bar.consist?
        }
        if uc_bars && uc_bars.size > 0
          display_unconsistent(uc_bars, xbars, as_cell.x, as_cell.y, cell.color, out)
          as_cell.remove_color(cell.color)
          return true
        end
        if uc_bars.empty?
          if fixed?(cells)
            @cells = cells
            return false
          end
        end
      end
      return false
    end

    def display_unconsistent(uc_bars, xbars, x, y, color, out)
      if out
        msg = "Unconsistent ("
        msg += uc_bars.collect {|bar|
          bar.name
        }.join(",")
        msg += ")\n"
        msg += "So Cell[#{x}, #{y}] color is not #{color}"
        out.display(xbars, msg)
      end
    end

    def solve(out = nil)
      b = Time.now
      xbars, ybars = create_bars(@cells)
      xhints, yhints = create_hints(@keys)
      attach_hint(xbars, ybars, xhints, yhints)
      (xbars+ybars).each do |bar|
        bar.nallow_range
      end
      if out
        out.display(xbars, "INITIALIZE", 0) 
      end
      solve_no_assumption(xbars, ybars, @cells, out)
      i = 0
      if !solved? && out
        out.display(xbars, "I Can' t fixed all area")
      end
      while i < Config::MAX_TIMES && !fixed?(@cells)
        if try_solve_one_assumption(xbars, ybars, out)
          (xbars+ybars).each do |bar|
            bar.nallow_range
          end
          if out
            out.display(xbars, "Now retry automatically setting (#{i})")
          end
          solve_no_assumption(xbars, ybars, @cells, out)
        else
          break
        end
        i += 1
      end
      @thinking_time = Time.now - b
      if !fixed?(@cells)
        @ansbars = xbars
      end
    end

    def solve_from_beginning(out=nil)
      @cells = create_initial_cells
      solve(out)
    end


    def solve_no_assumption(xbars, ybars, cells, out)
      num_for_break = 0
      num_for_display = fixed_nums(cells)
      fnum = 0
      step = 0
      bars = xbars + ybars
      Config::MAX_TIMES.times do |i|
        bars = unfixed_bars(bars)
        SOLVERS.each do |solver|
          bars.each_with_index do |bar, i|
            bar.send(solver)
          end
          fnum = fixed_nums(cells)
          if num_for_display < fnum
            num_for_display = fnum
            step += 1
            if out
              out.display(xbars, solver.to_s, step) 
            end
          end
          break if fixed?(cells)
        end
        break if fixed?(cells)
        if num_for_break < fnum
          num_for_break = fnum
        else
          break
        end
      end
      @ansbars = xbars
      return true
    end

    def unconsist_bars_index(cells)
      xbar_idxs = []
      ybar_idxs = []
      xbars, ybars = create_bars(cells)
      xhints, yhints = create_hints(@svkeys)
      attach_hint(xbars, ybars, xhints, yhints)
      xbars.each_with_index do |bar, i|
        if !bar.correct?
          xbar_idxs.push(i)
        end
      end
      ybars.each_with_index do |bar, i|
        if !bar.correct?
          ybar_idxs.push(i)
        end
      end

      [xbar_idxs, ybar_idxs]
    end

    def dump_bar(msg, bname, sname, bar, solver)
      if sname == solver && bname == bar.name
        puts msg
        bar.dump_info
      end
    end

  end
end
