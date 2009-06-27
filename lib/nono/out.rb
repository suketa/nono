module Nono
  module Out
    def create_msg
      if @plate.solved?
        "solved (#{@plate.thinking_time} sec.)"
      else
        "give up (#{@plate.thinking_time} sec.)"
      end
    end

    def yhint_max_size
      @plate.yhints.collect {|yhints|
        yhints.size
      }.max
    end

    def xhint_max_size
      @plate.xhints.collect {|xhints|
        xhints.size
      }.max
    end
  end
end
