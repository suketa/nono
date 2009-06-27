#! /usr/local/trunk/bin/ruby
require 'gtk2'
require 'nono/gtk/vnono'

Gtk.init
win = Nono::Gtk::VNono.new

win.show_all
Gtk.main
