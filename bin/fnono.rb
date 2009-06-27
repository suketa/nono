#! /usr/local/trunk/bin/ruby
begin
  require 'fox14'
rescue LoadError
  require 'fox12'
end
require 'nono/fx/vnono'
app = Fox::FXApp.new('Fnono', 'fnono')
app.init(ARGV)
vnono = Nono::Fx::VNono.new(app)
app.create()
app.run()
