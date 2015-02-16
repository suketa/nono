#! /usr/bin/env ruby

# GUI Selector for Xnono 
require 'rbconfig'
require 'optparse'

GUIS = {
  'vr/vruby' => 'wnono',
  'gtk2' => 'gnono',
  'fox12' => 'fnono',
  'fox14' => 'fnono',
  'tk' => 'tnono',
}

def select_gui(gui=nil)
  if gui
    key = GUIS.keys.find{|k| 
      /^#{gui}/ =~ k
    }
    if key  
      return GUIS[key]
    else
      puts "not found GUI nono corresponding to #{gui}"
      return nil
    end
  end
  GUIS.each do |k, v|
    begin
      require k
      return v
    rescue LoadError
    end
  end
  return nil
end

options = {}
opt = OptionParser.new do |opts|
  opts.banner = "Usage: guinono.rb [options]"
  opts.on("-g", "--gui GUI", "Run specified GUI nono. The available option is 'gtk' or 'vr' or 'fox' or 'tk'.") do |v|
    options[:gui] = v
  end
end
opt.parse!

gui = select_gui(options[:gui])
if !gui
  "not found GUI nono in your environment."
  exit
end

begin
  guipath = RbConfig::CONFIG['bindir'] + '/' + gui + '.rb'
rescue
  guipath = Config::CONFIG['bindir'] + '/' + gui + '.rb'
end
if File.exist?(guipath)
  load guipath
else
  load File.dirname(File.expand_path(__FILE__)) + '/' +  gui + '.rb'
end
