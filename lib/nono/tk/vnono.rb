require 'tk'
require 'nono/version'
require 'nono/gui/comvnono'
require 'nono/tk/vplate'
require 'nono/tk/config'

module Nono
  module Tk
    class VNono
      include Nono::Gui::COMVNono
      def initialize
        @msgarea = nil
        @vplate = nil
        create_menu
        create_msgarea
        create_canvas
      end
      def create_menu
        menu_spec = 
        [
        [['File', 0], 
         ['Open...', proc{open_clicked()}],
         ['Quit', proc{exit}]
        ],

        [['View', 0],
         ['Check', proc{check_clicked()}],
         ['Answer', proc{answer_clicked()}],
         
         # Solve Step by Step does not work fine.
         ['Solve Step by Step', proc{solve_step_clicked()}],

         ['Reset', proc{reset_clicked()}]
        ],

        [['Help', 0],
         ['About tnono...', proc{about_clicked()}]
        ]
        ]

        mbar = ::Tk.root.add_menubar(menu_spec)
      end

      def create_msgarea
        @msgarea = ::TkLabel.new {
          font(TkFont.new(Config::FONT))
          pack
        }
      end

      def create_canvas
        @vplate = VPlate.new {|x| 
          width 140
          height 10
          pack(:fill=>'both')
        }
      end

      def open_file_dialog
        ::Tk.getOpenFile
      end

      def display_error_dialog(msg)
        ::Tk.messageBox('icon'=>'error', 'type'=>'ok', 'title'=>'error', 'message'=> msg)
      end

      def print_msg(str)
        @msgarea.configure(:text => str)
      end

      def calc_width_from_plate
        width_from_plate
      end

      def calc_height_from_plate
        height_from_plate + 20
      end

      def resize(w, h)
        pos = ::Tk.root.winfo_geometry.sub(/[\d]+x[\d]+/, "")
        new_geometry = w.to_s + "x" + h.to_s + pos
        ::Tk.root.geometry(new_geometry)
        @vplate.width(w)
        @vplate.height(h)
      end

      def about_clicked
        AboutDlg.new
      end

    end

    class AboutDlg < TkDialog
      def title
        "about tnono"
      end

      def message
        "tnono #{Nono::VERSION}" +
        "\nRuby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]" +
        "\nTk #{::Tk::TK_PATCHLEVEL}"
      end
=begin
      def message_config
        {'wraplength' => '330'}
      end
=end
      def buttons
        ["OK"]
      end
    end

  end
end


