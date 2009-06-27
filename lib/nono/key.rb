module Nono
  class Key
    attr_accessor :pkey, :nkey
    attr_reader :orient, :pos, :color, :length, :from, :to, :idx
    def initialize(len, color, from, to, orient, pos, idx)
      @length = len
      @color = color
      @from = from
      @to = to
      @orient = orient
      @pos = pos
      @idx = idx
      @pkey = nil
      @nkey = nil
    end

    def set_to(val)
      if @to > val && val - @from + 1 >= length
        @to = val
      end
    end

    def set_from(val)
      if @from < val && @to - val + 1 >= length
        @from = val
      end
    end

    def set_from_forced(val)
      @from = val
    end

    def set_to_forced(val)
      @to = val
    end

    def double_range
      to = @from + @length - 1
      from = @to - @length + 1
      [from, to]
    end

    def set_from_by_pkey
      if pkey
        f = pkey.from + pkey.length
        if pkey.color == @color
          f += 1
        end
        set_from(f)
      end
    end

    def set_to_by_nkey
      if nkey
        t = nkey.to - nkey.length
        if nkey.color == @color
          t -= 1
        end
        set_to(t)
      end
    end

    def recalc_range_by_side_key
      set_from_by_pkey
      set_to_by_nkey
    end


    def range_includable?(r)
      if @from <= r.first && r.last <= @to && r.last - r.first + 1 <= @length
        true
      else
        false
      end
    end

    def set_range_by_includable_range(r)
      f = r.last - @length  + 1
      t = r.first + @length - 1
      set_from(f)
      set_to(t)
    end


  end
end
