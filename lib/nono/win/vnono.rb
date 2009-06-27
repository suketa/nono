require 'vr/vruby'
require 'vr/vrdialog'
require 'vr/vrmargin'
require 'nono/version'
require 'nono/gui/comvnono'
require 'nono/win/config'
require 'nono/win/vplate'

module Nono
  module Win
    class VNono < VRForm
      include VRMenuUseable
      include Nono::Gui::COMVNono
      include Nono::Win::Config
      SS_CENTER = 1
      def construct
        self.caption = "wnono"
        @file_menu = newMenu(true).set([["Open...", "open"], ["Quit", "quit"]])
        @view_menu = newMenu(true).set([["Check", "check"], 
                                       ["Answer", "answer"],
                                       ["Solve Step by Step", "solve_step"],
                                       ["Reset", "reset"]])
        @tool_menu = newMenu(true).set([["Font...", "font"]])
        @help_menu = newMenu(true).set([["About wnono", "about"]])
        menus = [["File", @file_menu],
                 ["View", @view_menu],
                 ["Tool", @tool_menu],
                 ["Help", @help_menu]]
        setMenu newMenu.set(menus)

        font = @screen.factory.newfont(win_fontname, win_fontsize)
        @msg_height = font.height + 4
        addControl(VRStatic, "msg", "", 0, 0, 60, @msg_height, SS_CENTER).
                   extend(VRMargin).initMargin(0,0,0,nil)
        addControl(VPlate, "vplate", "").extend(VRMargin).initMargin(0,@msg_height,0,0)
        menu_str_len = 0
        menus.collect {|m|
          m[0]
        }.each do |str|
          menu_str_len += (str.length + 2)
        end
        move(100, 100, menu_str_len * 10, 60 + @msg_height + 10)
      end

      include VRResizeSensitive
      def self_resize(w, h)
        if @vplate
          @msg.move(0, 0, w, @msg_height)
          @vplate.move(0, 0, w, h)
        end
      end

      def open_file_dialog
        openFilenameDialog
      end

      def display_error_dialog(msg)
        messageBox(msg, "Error")
      end

      def resize(nw, nh)
        x, y, w, h = windowrect
        move(x, y, nw, nh)
      end

      def calc_width_from_plate
        width_from_plate + 10
      end

      def calc_height_from_plate
        height_from_plate + 60 + @msg_height
      end

      def quit_clicked
        self.close
      end

      def print_msg(msg)
        font = @screen.factory.newfont(win_fontname, win_fontsize)
        @msg.setFont(font)
        @msg.caption = msg
      end

      def font_clicked
        f = chooseFontDialog(@f)
        if f
          @f = f
          msg = @msg.caption
          print_msg("")
          set_win_font(@f.fontface, @f.height)
          set_one_cell_size(0 - @f.height + 1)
          print_msg(msg)
          if @vplate
            @vplate.set_win_font(@f.fontface, @f.height)
            @vplate.set_one_cell_size(0 - @f.height + 1)
          end
          if @plate
            resize(calc_width_from_plate, calc_height_from_plate)
            @vplate.redraw_all_elements
          end
        end
      end

      def about_clicked
        msg = "wnono #{Nono::VERSION}"
        msg += "\r\n" + "Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
        msg += "\r\n" + "VisualuRuby #{SWin::VERSION}"
        messageBox msg, "about wnono"
      end

    end
  end
end

