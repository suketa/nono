#! /usr/local/trunk/bin/ruby
require 'optparse'
require 'nono/loader'
require 'nono/plate'
require 'nono/version'
require 'nono/htmlout'
require 'nono/textout'

step = false
opts = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options] <file>"
  opts.on("-s", "--step", "Display step by step") do |s|
    step = s
  end
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
  opts.on_tail("-v", "--version", "Show version") do
    puts "nono version #{Nono::VERSION}"
    exit
  end
end
if ARGV.size == 0
  puts opts
  exit
end

opts.parse!(ARGV)

ARGV.each do |file|
  if File.exist?(file)
    puts "--- #{file} ---"
    begin
      loader = Nono::Loader.new(file)
      plate = Nono::Plate.new(loader.xlines, loader.ylines)
      textout = Nono::TextOut.new(file, plate)
      if step
        plate.solve(textout)
      else
        plate.solve
      end
      textout.display
      htmlout = Nono::HTMLOut.new(file, loader.css_colors, plate)
      htmlout.display
    rescue Nono::NonoError
      puts $!
    end
  else
    puts "#{file} not found"
  end
end
