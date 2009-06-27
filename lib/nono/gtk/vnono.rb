require 'gtk2'
require 'nono/version'
require 'nono/gui/comvnono'
require 'nono/gtk/config'
require 'nono/gtk/vplate'

module Nono
  module Gtk
    class VNono < ::Gtk::Window
      include Nono::Gui::COMVNono
      include Nono::Gtk::Config
      def initialize
        super
        @box = nil
        signal_connect("destroy") do
          destroy
        end
        @vplate = nil
        @plate = nil
        @msgarea = nil
	@f = nil
        create_box
        create_menu
        create_controls
        create_plate
        set_title("gnono")
      end

      def create_box
        @box = ::Gtk::VBox.new(false, 0)
        add(@box)
      end

      def create_menu
        menubar = ::Gtk::MenuBar.new
        menuitem = ::Gtk::MenuItem.new("File")

        menu = ::Gtk::Menu.new
        mitem = ::Gtk::MenuItem.new("Open...")
        mitem.signal_connect("activate") do |win, evt|
          open_clicked
        end
        menu.append mitem
        mitem = ::Gtk::MenuItem.new("Quit")
        mitem.signal_connect("activate") do |win, evt|
          destroy
        end
        menu.append mitem

        menuitem.set_submenu menu

        menubar.append menuitem

        menuitem = ::Gtk::MenuItem.new("View")
        menu = ::Gtk::Menu.new
        mitem = ::Gtk::MenuItem.new("Check")
        mitem.signal_connect("activate") do |win, evt|
          check_clicked
        end
        menu.append mitem
        mitem = ::Gtk::MenuItem.new("Answer")
        mitem.signal_connect("activate") do |win, evt|
          answer_clicked
        end
        menu.append mitem
        mitem = ::Gtk::MenuItem.new("Solve Step by Step")
        mitem.signal_connect("activate") do |win, evt|
          solve_step_clicked
        end
        menu.append mitem
        mitem = ::Gtk::MenuItem.new("Reset")
        mitem.signal_connect("activate") do |win, evt|
          reset_clicked
        end
        menu.append mitem
        menuitem.set_submenu menu
        menubar.append menuitem

        menuitem = ::Gtk::MenuItem.new("Tool")
        menu = ::Gtk::Menu.new
        mitem = ::Gtk::MenuItem.new("Font...")
        mitem.signal_connect("activate") do |win, evt|
          font_clicked
        end
        menu.append mitem
        menuitem.set_submenu menu
        menubar.append menuitem

        menuitem = ::Gtk::MenuItem.new("Help")
        menu = ::Gtk::Menu.new
        mitem = ::Gtk::MenuItem.new("About gnono...")
        mitem.signal_connect("activate") do |win, evt|
          about_nono
        end
        menu.append mitem
        menuitem.set_submenu menu
        menubar.append menuitem

        @box.pack_start(menubar, false, true, 0)
      end

      def create_controls
        @msgarea = ::Gtk::Label.new
        @box.pack_start(@msgarea, false, true, 0)
      end

      def create_plate
        @vplate = VPlate.new
        @box.pack_start(@vplate, true, true, 0)
      end

      def destroy
        ::Gtk.main_quit
      end

      def open_file_dialog
        window = ::Gtk::FileSelection.new("file selection dialog")
        window.window_position = ::Gtk::Window::POS_MOUSE
        window.border_width = 0

        ret = window.run
        fname = window.filename
        window.destroy
        if ret == ::Gtk::Dialog::RESPONSE_OK
          fname
        else
          ""
        end
      end

      def display_error_dialog(msg)
        dlg = ::Gtk::MessageDialog.new(self, 
                                       ::Gtk::Dialog::MODAL,
                                       ::Gtk::MessageDialog::ERROR, 
                                       ::Gtk::MessageDialog::BUTTONS_OK,
                                       msg)
        dlg.run
        dlg.destroy
      end

      def calc_width_from_plate
        width_from_plate
      end

      def calc_height_from_plate
        height_from_plate + 30
      end

      def print_msg(str)
        @msgarea.text = str
      end

      def about_nono
        dlg = ::Gtk::Dialog.new("about gnono", self,
                                ::Gtk::Dialog::MODAL,
                                [::Gtk::Stock::OK, ::Gtk::Dialog::RESPONSE_OK])
        dlg.vbox.add(::Gtk::Label.new("gnono #{::Nono::VERSION}"))
        dlg.vbox.add(::Gtk::Label.new("Ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"))
        dlg.vbox.add(::Gtk::Label.new(sprintf("Ruby/GTK %d.%d.%d", *::Gtk::BINDING_VERSION)))
        dlg.vbox.add(::Gtk::Label.new("GTK+ #{::Gtk::MAJOR_VERSION}.#{::Gtk::MINOR_VERSION}.#{::Gtk::MICRO_VERSION}"))
        dlg.set_default_size(200, 150)
        dlg.vbox.show_all
        dlg.run
        dlg.destroy
      end

      def one_cell_size_from_font(font)
        fd = Pango::FontDescription.new(@f)
	l = create_pango_layout
	l.font_description = fd
	l.pixel_size[1] + 2
      end

      def font_clicked
        fontdlg = ::Gtk::FontSelectionDialog.new
	fontdlg.font_name = @f if @f
	ret = fontdlg.run
	if ret == ::Gtk::Dialog::RESPONSE_OK
	  font_name = fontdlg.font_name
	  if font_name
            @f = font_name
	    set_gtk_font(@f)
	    len = one_cell_size_from_font(@f)
	    set_one_cell_size(len)
	    if @vplate
	      @vplate.set_gtk_font(@f)
	      @vplate.set_one_cell_size(len)
	    end
	    if @plate
              resize(calc_width_from_plate, calc_height_from_plate)
	      @vplate.redraw_all_elements
	    end
	  end
	end
	fontdlg.destroy
      end

    end
  end
end
