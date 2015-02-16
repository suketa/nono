Gem::Specification.new do |s|
  s.name = 'nono'
  s.version = '0.1.9'
  s.summary = 'nonogram solver'
  s.description = 'solving nonogram and play nonogram puzzle game.'
  s.files = Dir.glob("bin/*.rb") + Dir.glob("lib/nono/**/*.rb") + Dir.glob("unittest/*.rb")
  s.executables = s.files.grep(/^bin\//) {|f|
    File.basename(f)
  }
  s.test_files = s.files.grep(/^unittest\//)
  s.require_paths = ['lib']
  s.homepage = 'https://github.com/suketa/nono'
  s.authors = ['Masaki Suketa']
  s.email = 'Masaki.Suketa@nifty.ne.jp'
  s.licenses = ['2-clause BSD License']
end
