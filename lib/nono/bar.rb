require 'nono/config'
module Nono
  class Bar
    attr_reader :cells
    attr_reader :name

    def get_range
      @range
    end

    def get_rangehint
      @rangehint
    end

    def initialize(cells, name)
      @cells = cells
      @range = cells.dup
      @rangehint = nil
      @name = name
    end

    def trim_range
      if !@range.empty?
        cell = @range.first
        while cell && cell.blank?
          @range.shift
          cell = @range.first
        end

        cell = @range.last
        while cell && cell.blank?
          @range.pop
          cell = @range.last
        end
      end
    end

    def nallow_range
      trim_range
      trim_fixed
      recalc_range
      recalc_range
      recalc_terminal_key_range
      recalc_range_by_fixed_cell
      recalc_range_by_fixed_cell
      recalc_key_range_includable_by_side_fixed_cell
      recalc_key_range_by_side_fixed_cell
      recalc_key_by_terminal_blank_cell

      nallow_color
    end

    def nallow_color
      cols = @rangehint.colors
      cols.push(Config::BLANK)
      @range.each do |cell|
        cell.set_colors(cols.dup)
      end
    end


    def fixed_f_by_key?(key, range = @range)
      l = key.length
      l.times do |i|
        if range[i] && range[i].color != key.color
          return false
        end
      end
      if range[l] && !range[l].fixed?
        return false
      end
      return true
    end

    def fixed_l_by_key?(key)
      fixed_f_by_key?(key, @range.reverse)
    end

    def trim_f_fixed_by_key(key)
      len = key.length
      len.times do |i|
        @range.shift
      end
    end

    def trim_l_fixed_by_key(key)
      len = key.length
      len.times do |i|
        @range.pop
      end
    end


    def trim_fixed
      trim_range
      key = @rangehint.first
      while key && fixed_f_by_key?(key)
        trim_f_fixed_by_key(key)
        trim_range
        @rangehint.shift
        key = @rangehint.first
      end
      key = @rangehint.last
      while key && fixed_l_by_key?(key)
        trim_l_fixed_by_key(key)
        trim_range
        @rangehint.pop
        key = @rangehint.last
      end
      @rangehint.reset_range_forced(0, @range.size - 1)
    end

    def attach_hint(hint)
      @rangehint = hint
    end

    def solve_by_same_length
      if @rangehint.min_length == @range.size
        fill_color_by_hint(@rangehint)
      end
    end

    def solve_by_larger_half
      @rangehint.keys.each do |key|
        from, to = key.double_range
        set_color(key.color, from, to)
      end
    end

    def solve_by_terminal_fixed
      f = @range.first
      if f && f.fixed?
        key = @rangehint.first
        if key 
          nkey = key.nkey
          if f.colored? && f.color == key.color
            to = key.length - 1
            set_color(key.color, 0, to)
            if nkey && key.color == nkey.color || !nkey
              set_blank(to + 1, to + 1)
            end
          end
        end
      end
      l = @range.last
      if l && l.fixed?
        key = @rangehint.last
        if key
          pkey = key.pkey
          if l.colored? && l.color == key.color
            to = key.length - 1
            set_r_color(key.color, 0, to)
            if pkey && key.color == pkey.color || !pkey
              set_r_blank(to + 1, to + 1)
            end
          end
        end
      end
    end

    def solve_by_inner_cell_fixed
      if @rangehint.first
        solve_by_inner_cell_fixed_and_first_key(@range, @rangehint.first, @rangehint.first.nkey)
        solve_by_inner_cell_fixed_and_first_key(@range.reverse, @rangehint.last, @rangehint.last.pkey)
      end
    end

    def set_color(color, from, to=nil, dcells=nil)
      if !to
        to = from
      end
      if !from
        return 
      end
      if !dcells 
        dcells = @range
      end
      (from..to).each do |i|
        if dcells[i] && i >= 0
          dcells[i].set_color(color)
        end
      end
      to - from + 1
    end

    def set_r_color(color, from, to=nil, dcells=nil)
      last = @range.size - 1
      t = last - from
      f = to || from
      f = last - f
      set_color(color, f, t, dcells)
    end

    def set_blank(from, to=nil, dcells=nil)
      set_color(Config::BLANK, from, to, dcells)
    end

    def set_r_blank(from, to=nil, dcells=nil)
      set_r_color(Config::BLANK, from, to, dcells)
    end

    def fixed?
      @cells.select {|cell|
        !cell.fixed?
      }.empty?
    end

    def solve_by_nallow_space(hint = @rangehint)
      if hint
        key = hint.min_length_key
        bars = bars_split_by_blank
        if key 
          bars.each do |bar|
            if bar.length < key.length
              bar.set_blank(0, bar.length - 1)
            end
          end
        end
        bar = bars.first
        key = hint.first
        if key && bar
          if bar.length < key.length
            bar.set_blank(0, bar.length - 1)
          end
        end
        bar = bars.last
        key = hint.last
        if key && bar
          if bar.length < key.length
            bar.set_blank(0, bar.length - 1)
          end
        end
      end
    end

    def bars_split_by_blank
      bars = []
      cells = []
      @range.each do |cell|
        if cell.blank?
          if !cells.empty?
            bars.push(Bar.new(cells, @name))
            cells = []
          end
        else
          cells.push(cell)
        end
      end
      if !cells.empty?
        bars.push(Bar.new(cells, @name))
      end
      bars
    end

    def colored_bars(r = @range)
      bars = []
      cells = []
      precel = r.first
      r.each do |cell|
        if cell.color != precel.color
          if !cells.empty?
            bars.push(Bar.new(cells, @name))
            cells = []
          end
        end
        if cell.colored?
          cells.push(cell)
        end
        precel = cell
      end

      if !cells.empty?
        bars.push(Bar.new(cells, @name))
      end
      bars
    end

    def length
      @cells.size
    end

    def all_fixed_nums?(hint)
      bars = colored_bars
      if bars.size != hint.size
        return false
      end
      bars.each_with_index do |bar, i|
        key = hint.keys[i]
        if bar.length != key.length
          return false
        end
      end
      return true
    end

    def solve_by_fixed_nums
      if all_fixed_nums?(@rangehint)
        set_color(Config::BLANK, 0, @range.size - 1)
      end
    end

    def all_non_blank_fixed?
      bars = bars_split_by_blank
      if bars.size != @rangehint.size
        return false
      end
      bars.each_with_index do |bar, i|
        if bar.length != @rangehint.keys[i].length
          return false
        end
      end
      true
    end
        
    def solve_by_all_non_blank_fixed
      if all_non_blank_fixed?
        bars = bars_split_by_blank
        bars.each_with_index do |bar, i|
          bar.set_color(@rangehint.keys[i].color, 0, bar.length - 1)
        end
      end
    end

    def solve_by_max_fixed
      key = @rangehint.max_length_key
      index = index_fixed_by_key(key)
      if index
        bf = index - 1
        remove_color(key.color, bf, bf)
        af = index + 1
        remove_color(key.color, af, af)
      end
    end

    def remove_color(color, from, to, dcells=@range)
      (from..to).each do |i|
        if dcells[i] && i >= 0
          dcells[i].remove_color(color)
        end
      end
      to - from + 1
    end

    def index_fixed_by_key(key)
      if key
        @range.each_with_index do |cell, i|
          if cell.colored? && cell.color == key.color
            if bgn_index_fixed_by_key?(i, key)
              return i
            end
          end
        end
      end
      nil
    end

    def bgn_index_fixed_by_key?(idx, key)
      key.length.times do |i|
        cell = @range[idx + i]
        if cell && cell.color != key.color || !cell
          return false
        end
      end
      true
    end


    def fill_color_by_key(from, key)
      to = from + key.length - 1
      num = set_color(key.color, from, to)
      if key.nkey && key.color == key.nkey.color
        set_blank(to + 1)
        num += 1
      end
      num
    end

    def fill_color_by_hint(hint)
      from = 0
      hint.keys.each do |key|
        from += fill_color_by_key(from, key)
      end
    end

    def solve_by_terminal_unreached
      key = @rangehint.first
      if key
        c = @range[key.length]
        if c && c.color == key.color
          set_blank(0, 0)
        end
      end
    end

    def solve_by_first_fixed(dcells, key, nkey)
      cell = dcells.first
      if cell.colored? && cell.color == key.color
        to = key.length - 1
        set_color(key.color, 0, to, dcells)
        if nkey && key.color == nkey.color
          set_blank(to + 1, to + 1, dcells)
        end
      end
    end

    def first_colored_cell_index(dcells = nil)
      index = nil
      dcells.each_with_index do |cell, i|
        if cell.colored? 
          index = i
          break
        end
      end
      index
    end

    def solve_by_inner_cell_fixed_and_first_key(dcells, key, nkey)
      index = first_colored_cell_index(dcells)
      if index
        if key.length - 1 > index && dcells[index].color == key.color
          from = index
          to = key.length - 1
          set_color(key.color, from, to, dcells)
          if dcells[to + 1] && 
             dcells[to + 1].fixed? &&
             dcells[to + 1].color != key.color
            set_color(key.color, 0, 0, dcells)
          end
          if dcells[to + 1] && 
             dcells[to + 1].fixed? &&
             dcells[to + 1].color == key.color
            set_blank(0, 0, dcells)
          end
        end
        if index == 1 && key.length == 1 && dcells[index].color == key.color
          set_blank(0, 0, dcells)
          if nkey && nkey.color == key.color
            set_blank(2, 2, dcells)
          end
        end
        if key.length - 1 == index && dcells[index].color == key.color
          if dcells[index + 1] && 
             dcells[index + 1].fixed? &&
             dcells[index + 1].color != key.color
            set_color(key.color, 0, index, dcells)
          end
          if dcells[index + 1] && 
             dcells[index + 1].fixed? &&
             dcells[index + 1].color == key.color
            set_blank(0, 0, dcells)
          end
        end
      end

    end

    def include_colored?
      @cells.find{|cell| cell.colored?}
    end

    def nallow_area_by_key(key)
      f = first_cell_index_filled_by_color(key.color)
      if f
        from = f + key.length
        set_blank(from, @range.length - 1)
      end
      l = last_cell_index_filled_by_color(key.color)
      if l
        to = l - key.length
        set_blank(0, to)
      end
    end

    def solve_by_same_nums
      bars = bars_split_by_blank
      cbars = bars.select {|bar|
        bar.include_colored?
      }
      if cbars.size == @rangehint.size
        bars.each do |bar|
          if !bar.include_colored?
            bar.set_blank(0, bar.length - 1)
          end
        end
        cbars.each_with_index do |bar, i|
          key = @rangehint.keys[i]
          bar.nallow_area_by_key(key)
        end
      end
    end

    def unfixed_cell_index_with_side_same_colored(col)
      @range.each_with_index do |cell, i|
        if 0 < i && i < @range.length - 1
          p = @range[i-1]
          n = @range[i+1]
          if n && p && n.colored? && p.colored? && n.color == p.color && n.color == col && !cell.fixed?
            return i
          end
        end
      end
      nil
    end

    def pre_colored_length(idx)
      id = idx - 1
      cell = @range[id]
      len = 0
      kcell = cell
      while cell && cell.colored? && cell.color == kcell.color && id >= 0
        id -= 1
        len += 1
        cell = @range[id]
      end
      len
    end

    def next_colored_length(idx)
      id = idx + 1
      cell = @range[id]
      kcell = cell
      len = 0
      while cell && cell.colored? && cell.color == kcell.color
        id += 1
        len += 1
        cell = @range[id]
      end
      len
    end

    def solve_by_one_unfixed_cell
      cols = @rangehint.colors
      cols.each do |col|
        idx = unfixed_cell_index_with_side_same_colored(col)
        if idx
          mkey = @rangehint.keys.select {|key|
            key.color == col
          }.max {|k1,k2| k1.length <=> k2.length}
          plen = pre_colored_length(idx)
          nlen = next_colored_length(idx)
          if mkey && plen + nlen + 1 > mkey.length
            remove_color(mkey.color, idx, idx)
          end
        end
      end
    end

    def colored_cells(color)
      dcells = []
      @cells.each_with_index do |cell, i|
        if cell.color == color
          dcells.push(cell)
        elsif !dcells.empty?
          break
        end
      end
      dcells
    end

    def first_cell_index_filled_by_color(color, dcells=nil, bgn=-1)
      index = nil
      if !dcells
        dcells = @range
      end
      dcells.each_with_index do |cell, i|
        if cell.color == color && i > bgn
          index = i
          break
        end
      end
      index
    end

    def last_cell_index_filled_by_color(color, dcells=nil)
      if !dcells
        dcells = @range
      end
      f = first_cell_index_filled_by_color(color, dcells.reverse)
      if f
        dcells.size - 1 - f
      else
        nil
      end
    end

    def recalc_range
      @rangehint.keys.each do |key|
        from = settable_index_by_key(key)
        if from
          key.set_from(from)
        end
        to = settable_last_index_by_key(key)
        if to
          key.set_to(to)
        end
      end
      @rangehint.keys.each do |key|
        key.recalc_range_by_side_key
      end
    end

    def settable_index_by_key(key)
      idx = key.from
      ret = nil
      to = @range.size - 1
      (idx..to).each do |i|
        cell = @range[i]
        next if cell.blank?
        if settable_by_key?(i, key)
          ret = i
          break
        end
      end
      ret
    end

    def settable_by_key?(from, key)
      to = from + key.length - 1
      (from .. to).each do |i|
        if @range[i] && (@range[i].blank? || @range[i].colored? && @range[i].color != key.color) || !@range[i]
          return false
        end
      end
      true
    end

    def settable_last_index_by_key(key)
      ret = nil
      idx = key.to
      cell = @range[idx]
      while cell && idx >= 0
        if settable_last_by_key?(idx, key)
          ret = idx
          break
        end
        idx = idx - 1
        cell = @range[idx]
      end
      ret
    end

    def settable_last_by_key?(to, key)
      from = to - key.length + 1
      settable_by_key?(from, key)
    end
        

    def solve_by_unreached_area
      @rangehint.keys.each do |key|
        if !key.pkey
          set_blank(0, key.from - 1)
        else
          f = key.pkey.to + 1
          t = key.from - 1
          if f <= t
            set_blank(f, t)
          end
        end
        if !key.nkey
          set_blank(key.to + 1, @range.size - 1)
        end
      end
    end

    def recalc_range_by_fixed_cell
      ranges = colored_index_ranges
      ranges.each do |ir|
        keys = @rangehint.keys_range_includable(ir)
        if keys && keys.size == 1
          key = keys[0]
          key.set_range_by_includable_range(ir)
        end
      end
    end

    def colored_index_ranges
      ranges = []
      cells = []
      precel = @range.first
      from = nil
      @range.each_with_index do |cell, i|
        if cell.color != precel.color
          if from
            to = i - 1
            ranges.push(from .. to)
            from = nil
          end
        end
        if cell.colored? && !from
          from = i
        end
        precel = cell
      end
      if from
        ranges.push(from .. @range.size - 1)
      end
      ranges
    end

    def recalc_key_range_includable_by_side_fixed_cell
      ranges = colored_index_ranges
      ranges.each do |ir|
        keys = @rangehint.keys_range_includable(ir)
        if keys && keys.size == 1
          key = keys[0]
          f = ir.last - key.length
          if 0 <= f && f < @range.size
            pcell = @range[f]
            if pcell && pcell.colored? && pcell.color == key.color
              key.set_from(f + 2)
            end
          end
          l = ir.first + key.length
          if 0 <= l && l < @range.size
            lcell = @range[l]
            if lcell && lcell.colored? && lcell.color == key.color
              key.set_to(l - 2)
            end
          end
        end
      end
    end

    def recalc_key_range_by_side_fixed_cell
      @rangehint.keys.each do |key|
        i = key.from - 1
        if 0 <= i && @range[i] && @range[i].color == key.color
          key.set_from(i + 2)
        end
        i = key.to + 1
        if @range[i] && @range[i].color == key.color
          key.set_to(i - 2)
        end
      end
    end

    def recalc_key_by_terminal_blank_cell
      @rangehint.keys.each do |key|
        i = key.from
        while @range[i].blank?
          i += 1
        end
        key.set_from(i)

        i = key.to
        while @range[i].blank?
          i -= 1
        end
        key.set_to(i)
      end
    end

    def recalc_terminal_key_range
      key = @rangehint.first
      if key 
        idx = first_index_colored_cell(key.color)
        if idx
          to = idx + key.length - 1
          key.set_to(to)
        end
      end
      key = @rangehint.last
      if key
        idx = last_index_colored_cell(key.color)
        if idx
          from = idx - key.length + 1
          key.set_from(from)
        end
      end
    end

    def first_index_colored_cell(color)
      @range.each_with_index do |cell, i|
        if cell.color == color
          return i
        end
      end
      nil
    end

    def last_index_colored_cell(color)
      i = @range.size - 1
      while i >= 0
        if @range[i].color == color
          return i
        end
        i -= 1
      end
      nil
    end

    def first_index_unfixed_cell
      i = 0
      while @cells[i]
        if !@cells[i].fixed?
          return i
        end
        i += 1
      end
      nil
    end

    def last_index_unfixed_cell
      i = @cells.size - 1
      while @cells[i] && i >= 0
        if !@cells[i].fixed?
          return i
        end
        i -= 1
      end
      nil
    end


    def solve_by_zero_key
      key = @rangehint.first
      if key && key.length == 0
        set_blank(0, @range.size - 1)
      end
    end

    def solve_by_one_key_includable_colored_range
      ranges = colored_index_ranges
      ranges.each do |ir|
        keys = @rangehint.keys_range_includable(ir)
        if keys  && keys.size == 1
          key = keys[0]
          if key.length == ir.last - ir.first + 1
            pkey = key.pkey
            if pkey && pkey.color == key.color
              set_blank(ir.first - 1, ir.first - 1)
            elsif !pkey
              set_blank(0, ir.first - 1)
            end
            
            nkey = key.nkey
            if nkey && nkey.color == key.color
              set_blank(ir.last + 1, ir.last + 1)
            elsif !nkey
              set_blank(ir.last + 1, @range.size - 1)
            end
          end
        end
      end
    end

    def solve_by_includable_same_length_key
      ranges = colored_index_ranges
      ranges.each do |ir|
        col = @range[ir.first].color
        keys = @rangehint.keys_range_includable(ir).select {|key|
          key.color == col
        }
        if keys && keys.size > 0 && same_length_keys?(keys, ir.last - ir.first + 1)
          remove_color(col, ir.first - 1, ir.first - 1)
          remove_color(col, ir.last + 1, ir.last + 1)
        end
      end
    end

    def same_length_keys?(keys, len)
      keys.each do |key|
        if key.length != len
          return false
        end
      end
      true
    end

    def solve_by_side_cell_fixed
      ranges = colored_index_ranges.select {|ir|
        idx = ir.first - 1
        idx >= 0 && @range[idx] && @range[idx].fixed?
      }
      ranges.each do |ir|
        col = @range[ir.first].color
        keys = @rangehint.keys_range_includable(ir).select {|key|
          key.color == col
        }
        len = keys.collect {|key|
          key.length
        }.min
        if len
          set_color(col, ir.first, ir.first + len - 1)
        end
      end

      ranges = colored_index_ranges.select {|ir|
        idx = ir.last + 1
        @range[idx] && @range[idx].fixed?
      }
      ranges.each do |ir|
        col = @range[ir.first].color
        keys = @rangehint.keys_range_includable(ir).select {|key|
          key.color == col
        }
        len = keys.collect {|key|
          key.length
        }.min
        if len
          set_color(col, ir.last - len + 1, ir.last)
        end
      end
    end

    def solve_by_inner_terminal_unreached
      ranges = ranges_split_by_blank
      ranges.each do |ir|
        rkeys = @rangehint.keys_range_includable((ir.first .. ir.first))
        colors = rkeys.collect {|key| key.color}
        colors.each do |col|
          keys = rkeys.select{|key| key.color == col}
          if keys.size > 0
            key  = keys[0]
            if same_length_keys?(keys, key.length)
              idx = ir.first + key.length
              cell = @range[idx] 
              if idx <= ir.last && cell && cell.color == key.color
                remove_color(key.color, ir.first, ir.first)
              end
            end
          end
        end
        rkeys = @rangehint.keys_range_includable(ir.last .. ir.last)
        colors = rkeys.collect {|key| key.color}
        colors.each do |col|
          keys = rkeys.select{|key| key.color == col}
          if keys.size > 0
            key  = keys[0]
            if same_length_keys?(keys, key.length)
              idx = ir.last - key.length
              cell = @range[idx] 
              if idx > ir.first && cell && cell.color == key.color
                remove_color(key.color, ir.last, ir.last)
              end
            end
          end
        end
        
      end
    end

    def solve_by_key_range
      @rangehint.keys.each do |key|
        pkey = key.pkey
        f = 0
        if pkey 
          f = pkey.to + 1
        end
        t = key.from - 1
        if 0 <= f && f <= t
          set_blank(f, t)
        end

        nkey = key.nkey
        t = @range.size - 1
        if nkey
          t = nkey.from - 1
        end
        f = key.to + 1
        if 0 <= f && f <= t
          set_blank(f, t)
        end
      end
    end
        


    def ranges_split_by_blank
      ranges = []
      f = nil
      @range.each_with_index do |cell, i|
        if cell.blank?
          if f
            t = i - 1
            ranges.push((f .. t))
            f = nil
          end
        else
          if !f
            f = i
          end
        end
      end
      if f
        ranges.push(f .. @range.size - 1)
      end
      ranges
    end

    def correct?
      bars = colored_bars(@cells)
      keys = @rangehint.svkeys
      if fixed?
        if keys.size == 1 && keys[0].length == 0 && bars.size == 0
          return true
        elsif bars.size != keys.size 
          return false
        end
        bars.each_with_index do |bar, i|
          if bar.length != keys[i].length || bar.cells[0].color != keys[i].color
            return false
          end
        end
      else
        return false
      end
      return true
    end

    def consist?
      if fixed?
        bars = colored_bars(@cells)
        keys = @rangehint.svkeys
        if bars.size != keys.size
          return false
        end
        bars.each_with_index do |bar, i|
          if bar.length != keys[i].length || bar.cells[0].color != keys[i].color
            return false
          end
        end
      else
        bars = colored_bars
        keys = @rangehint.keys
        if bars && keys
          # Ruby 1.9 feature
          # mbar = bars.max_by {|bar| bar.length}
          # mkey = keys.max_by {|key| key.length}
          mbar = bars.max{|b1, b2| b1.length <=> b2.length}
          mkey = keys.max{|k1, k2| k1.length <=> k2.length}

          if mbar && mkey && mbar.length > mkey.length
            return false
          end
        end
        ary = []
        bars = bars_split_by_blank.select {|bar|
          bar.fixed?
        }
        if bars 
          bars.each do |bar|
            ary += bar.colored_bars
          end
        end
        if ary && keys
          # Ruby 1.9 feature
          # mbar = ary.min_by {|bar| bar.length}
          # mkey = keys.min_by {|key| key.length}
          mbar = ary.min{|b1, b2| b1.length <=> b2.length}
          mkey = keys.min{|k1, k2| k1.length <=> k2.length}

          if mbar && mkey && mbar.length < mkey.length
            return false
          end
        end
      end
      return true
    end

    def unfixed_cell_size
      @range.select {|cell|
        !cell.fixed?
      }.size
    end

    def dump_info
      puts ""
      puts "------ #{@name} ------"
      @range.each do |cell|
        p cell
      end
      @rangehint.dump_info
      puts ""
    end

    def dump_info_full
      puts ""
      puts "------ #{@name} ------"
      @cells.each do |cell|
        p cell
      end
      @rangehint.dump_info_full
    end

  end

end
