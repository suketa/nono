module Nono
  class Hint
    attr_reader :keys
    attr_reader :svkeys
    def initialize(keys)
      @keys = keys
      @svkeys = keys.dup
      set_from_to
      create_keys_order
    end

    def set_from_to
      @to = keys.collect{|key|
        key.to
      }.max
      if !@to
        @to = 0
      end

      @from = keys.collect{|key|
        key.from
      }.min
      if !@from
        @from = 0
      end
    end

    def create_keys_order
      pkey = nil
      @keys.each do |key|
        key.nkey = nil
        key.pkey = pkey
        if pkey
          pkey.nkey = key 
        end
        pkey = key
      end
    end

    def size
      @keys.size
    end

    def init_range
      @keys.each_with_index do |key, i|
        pkeys = @keys[0..i-1]
        if i == 0
          pkeys = []
        end
        nkeys = @keys[i+1 .. -1]
        phint = Hint.new(pkeys)
        nhint = Hint.new(nkeys)
        to = @to - nhint.min_length
        if @keys[i + 1] && key.color == @keys[i + 1].color
          to -= 1
        end
        key.set_to(to)

        from = @from + phint.min_length
        if @keys[i - 1] && i > 0 && key.color == @keys[i - 1].color
          from += 1
        end

        key.set_from(from)
      end
    end

    def min_length
      len = 0
      @keys.each_with_index do |key, i|
        len += key.length
        if @keys[i + 1]
          if key.color == @keys[i + 1].color
            len += 1
          end
        end
      end
      len
    end

    def first
      @keys.first
    end

    def last
      @keys.last
    end

    def min_length_key
      # Ruby 1.9 feature
      # @keys.min_by{|key| key.length}
      @keys.min{|k1, k2| k1.length <=> k2.length}
    end

    def max_length_key
      # Ruby 1.9 feature
      # @keys.max_by{|key| key.length}
      @keys.max{|k1, k2| k1.length <=> k2.length}
    end


    def reset_range(from, to)
      @keys.each do |key|
        key.set_from(from)
        key.set_to(to)
      end
    end

    def reset_range_forced(from, to)
      @keys.each do |key|
        key.set_from_forced(from)
        key.set_to_forced(to)
      end
      set_from_to
      init_range
      create_keys_order
    end

    def keys_range_includable(r)
      @keys.select {|k|
        k.range_includable?(r)
      }
    end

    def shift
      @keys.shift
    end

    def pop
      @keys.pop
    end

    def colors
      @keys.collect {|key|
        key.color
      }
    end

    def dump_info
      @keys.each do |key|
        puts "len=#{key.length} from=#{key.from} to=#{key.to} col=#{key.color}"
      end
    end

    def dump_info_full
      @svkeys.each do |key|
        puts "len=#{key.length} from=#{key.from} to=#{key.to} col=#{key.color}"
      end
    end
  end
end
