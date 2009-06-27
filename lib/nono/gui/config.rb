module Nono
  module Gui
    module Config
      ONE_CELL_SIZE = 20
      MARGIN = 20
      NG_MARK_SIZE = [MARGIN, ONE_CELL_SIZE].min * 0.6
      NG_MARK_BGN  = MARGIN - NG_MARK_SIZE - 2
      NG_MARK_OFFSET = (ONE_CELL_SIZE - NG_MARK_SIZE) / 2.0

      def one_cell_size
        if !@one_cell_size
          @one_cell_size = ONE_CELL_SIZE
        end
        @one_cell_size
      end

      def margin
        if !@margin
          @margin = MARGIN
        end
        @margin
      end

      def ng_mark_size
        if !@ng_mark_size
          @ng_mark_size = [margin, one_cell_size].min * 0.6
        end
        @ng_mark_size
      end

      def ng_mark_bgn
        if !@ng_mark_bgn
          @ng_mark_bgn = margin - ng_mark_size - 2
        end
        @ng_mark_bgn
      end

      def ng_mark_offset
        if !@ng_mark_offset
          @ng_mark_offset = (one_cell_size - ng_mark_size) / 2.0
        end
        @ng_mark_offset
      end

      def set_one_cell_size(size)
        @one_cell_size = size
        @ng_mark_size = [margin, one_cell_size].min * 0.6
        @ng_mark_bgn  = margin - ng_mark_size - 2
        @ng_mark_offset = (one_cell_size - ng_mark_size) / 2.0
      end

    end
  end
end
