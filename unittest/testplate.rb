require 'test/unit'
require 'nono/plate'
require 'nono/key'
require 'nono/config'
require 'nono/hint'

class TestPlate < Test::Unit::TestCase
  def test_initialize
    xlines = []
    ylines = []
    5.times do |i|
      xlines.push(i.to_s)
    end
    10.times do |i|
      ylines.push(i.to_s)
    end
    plate = Nono::Plate.new(xlines, ylines)
    assert_equal(50, plate.cells.size)
  end
  def test_xhint
    xlines = []
    ylines = []
    xlines.push("1,2")
    ylines.push("3,4,5")
    plate = Nono::Plate.new(xlines, ylines)
    xhint = plate.xhints[0]
    assert_equal(2, xhint.size)
  end
end

