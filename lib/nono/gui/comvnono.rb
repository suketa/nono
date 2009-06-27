require 'nono/out'
require 'nono/loader'
require 'nono/plate'
require 'nono/gui/config'
module Nono
  module Gui
    module COMVNono
      include Nono::Out
      include Nono::Gui::Config

      def width_from_plate(plate = @plate)
        xhint_size = xhint_max_size
        margin + one_cell_size * (xhint_size + plate.width) + margin
      end

      def height_from_plate(plate = @plate)
        yhint_size = yhint_max_size
        margin + one_cell_size * (yhint_size + plate.height) + margin
      end

      def open_clicked
        file = open_file_dialog
        if file && file != ""
          load_file(file)
        end
      end

      def load_file(file)
        begin
          loader = Nono::Loader.new(file)
          plate = Nono::Plate.new(loader.xlines, loader.ylines)
          set_plate(plate, loader.css_colors)
        rescue Nono::NonoError
          display_error_dialog($!.to_s)
          return
        end
      end

      def set_plate(plate, colors)
        print_msg("")
        @colors = colors
        @plate = plate
        @vplate.set_plate(@plate, colors)
        resize(calc_width_from_plate, calc_height_from_plate)
      end

      def answer_clicked
        if @plate
          if @vplate.display_answer
            print_msg("solved (#{@plate.thinking_time} sec.)")
          else
            print_msg("unsolved")
          end
        end
      end

      def check_clicked
        if @plate
          if @vplate.check_answer
            print_msg("correct")
          else
            print_msg("mistake")
          end
        end
      end

      def solve_step_clicked
        if @plate
          if @vplate.solve_step_by_step
            print_msg("solved (#{@plate.thinking_time} sec.)")
          else
            print_msg("unsolved")
          end
        end
      end

      def reset_clicked
        print_msg("")
        if @plate
          @vplate.reset
        end
      end

    end
  end
end
