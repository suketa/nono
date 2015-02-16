#! /usr/bin/env ruby
require 'gtk2'
require 'nono/gtk/vnono'

Gtk.init
win = Nono::Gtk::VNono.new

win.show_all
Gtk.main
