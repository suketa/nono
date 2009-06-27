require 'test/unit'
require 'nono/config'
require 'nono/key'

class TestKey < Test::Unit::TestCase
  def test_initialize
    key = Nono::Key.new(5, 'AA', 0, 7, Nono::Config::X, 1, 1)
  end
  def test_double_range
    key = Nono::Key.new(6, 'XX', 0, 9, Nono::Config::X, 1, 1)
    from, to = key.double_range
    assert_equal(5, to)
    assert_equal(4, from)
  end

  def test_range_includable_01
    key = Nono::Key.new(1, 'XX', 0, 3, Nono::Config::X, 0, 0)
    assert(key.range_includable?(1..1))
    assert(!key.range_includable?(4..4))
  end

  def test_range_includable_02
    key = Nono::Key.new(1, 'XX', 0, 3, Nono::Config::X, 0, 0)
    assert(!key.range_includable?(2..3))
  end

end
