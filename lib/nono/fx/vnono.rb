require 'nono/version'
require 'nono/gui/comvnono'
require 'nono/fx/vplate'
require 'nono/fx/config'

module Nono
  module Fx
    class VNono < Fox::FXMainWindow
      include Nono::Gui::Config
      include Nono::Gui::COMVNono

      def create
        super
        show(Fox::PLACEMENT_SCREEN)  
      end

      def initialize(app)
        super(app, "fnono", nil, nil, Fox::DECOR_ALL, 0, 0, 200, 120)
        create_menu
        create_frame
        create_msgarea
        create_vplate
      end

      def create_menu
        menubar = Fox::FXMenuBar.new(self, Fox::LAYOUT_SIDE_TOP|Fox::LAYOUT_FILL_X)

        filemenu = Fox::FXMenuPane.new(self)
        Fox::FXMenuCommand.new(filemenu, "Open...").connect(Fox::SEL_COMMAND){open_clicked}
        Fox::FXMenuCommand.new(filemenu, "Quit", nil, getApp(), Fox::FXApp::ID_QUIT)
        Fox::FXMenuTitle.new(menubar, "File", nil, filemenu)

        viewmenu = Fox::FXMenuPane.new(self)
        Fox::FXMenuCommand.new(viewmenu, "Check").connect(Fox::SEL_COMMAND){check_clicked}
        Fox::FXMenuCommand.new(viewmenu, "Answer").connect(Fox::SEL_COMMAND){answer_clicked}
        Fox::FXMenuCommand.new(viewmenu, "Solve Step by Step").connect(Fox::SEL_COMMAND){solve_step_clicked}
        Fox::FXMenuCommand.new(viewmenu, "Reset").connect(Fox::SEL_COMMAND){reset_clicked}
        Fox::FXMenuTitle.new(menubar, "View", nil, viewmenu)

	toolmenu = Fox::FXMenuPane.new(self)
	Fox::FXMenuCommand.new(toolmenu, "Font...").connect(Fox::SEL_COMMAND){font_clicked}
	Fox::FXMenuTitle.new(menubar, "Tool", nil, toolmenu)

        helpmenu = Fox::FXMenuPane.new(self)
        Fox::FXMenuCommand.new(helpmenu, "About fnono...").connect(Fox::SEL_COMMAND) {about_clicked}
        Fox::FXMenuTitle.new(menubar, "Help", nil, helpmenu)
      end


      def create_frame
        @frame = Fox::FXVerticalFrame.new(self, Fox::FRAME_SUNKEN|Fox::FRAME_THICK|Fox::LAYOUT_FILL_X|Fox::LAYOUT_FILL_Y)
      end

      def create_msgarea
        @msgarea = Fox::FXLabel.new(@frame, " ", nil, Fox::LAYOUT_CENTER_X)
      end

      def create_vplate
        @vplate = VPlate.new(@frame)
        @font = Fox::FXFont.new(getApp, Config::FONTNAME, Config::FONTSIZE)
        @font.create
        @vplate.setFont(@font)
      end

      def open_file_dialog
        Fox::FXFileDialog.getOpenFilename(self,"File Selection","")
      end

      def display_error_dialog(msg)
        Fox::FXMessageBox.error(self, Fox::MBOX_OK,"Error", msg)
      end

      def calc_width_from_plate
        width_from_plate + 10
      end

      def calc_height_from_plate
        height_from_plate + 60
      end

      def print_msg(str)
        msg = str
        if msg == ""
          msg = " "
        end
        @msgarea.setText(msg)
      end

      def about_clicked
        msg = "fnono #{Nono::VERSION}"
        msg += "\n" + "Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
        msg += "\n" + "FXRuby #{Fox.fxrubyversion}"
        msg += "\n" + "FOX #{Fox.fxversion}"
        Fox::FXMessageBox.information(self, Fox::MBOX_OK,"about fnono", msg)
      end

      def font_clicked
        fontdlg = Fox::FXFontDialog.new(self, "font selection", Fox::DECOR_BORDER|Fox::DECOR_TITLE)
        fontdlg.fontSelection = @font.fontDesc if @font
        if fontdlg.execute != 0
          @font = Fox::FXFont.new(app, fontdlg.fontSelection)
          @font.create
	  set_one_cell_size(@font.fontHeight)
	  if @vplate
            @vplate.setFont(@font)
	    @vplate.set_one_cell_size(@font.fontHeight)
	  end
	  if @plate
	    resize(calc_width_from_plate, calc_height_from_plate)
	    @vplate.update(0, 0, @vplate.width, @vplate.height)
	  end
	end
      end

    end
  end
end
