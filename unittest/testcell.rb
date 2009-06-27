require 'nono/cell'
require 'test/unit'

class TestCell < Test::Unit::TestCase
  def test_initialize
    cell = Nono::Cell.new(0,0,[])
  end
  def test_fixed?
    colors = [0,1]
    cell = Nono::Cell.new(0,0, colors)
    assert(!cell.fixed?)
    cell = Nono::Cell.new(0,0, [0])
    assert(cell.fixed?)
  end
  def test_set_blank
    colors = [0,1]
    cell = Nono::Cell.new(0,0, colors)
    cell.set_blank
    assert(cell.fixed?)
  end
  def test_color
    colors = [0,1]
    cell = Nono::Cell.new(0,0, colors)
    assert_equal(nil, cell.color)
    cell.set_blank
    assert_equal('  ', cell.color)
  end
  def test_set_color
    colors = ['AA', 'BB']
    cell = Nono::Cell.new(0, 0, colors)
    cell.set_color('BB')
    assert_equal('BB', cell.color)
    assert(cell.fixed?)
    cell.set_color('AA')
    assert_equal('BB', cell.color)
  end
  def test_x
    colors = ['AA', 'BB']
    cell = Nono::Cell.new(2, 0, colors)
    assert_equal(2, cell.x)
  end
  def test_y
    colors = ['AA', 'BB']
    cell = Nono::Cell.new(2, 0, colors)
    assert_equal(0, cell.y)
  end

end
