require 'test/unit'
require 'nono/hint'
require 'nono/key'
require 'nono/config'

class TestHint < Test::Unit::TestCase
  def test_min_length
    keys = []
    keys.push(Nono::Key.new(1, 'XX', 0, 6, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 6, Nono::Config::X, 0, 1))
    hint = Nono::Hint.new(keys)
    assert_equal(4, hint.min_length)

    keys = []
    keys.push(Nono::Key.new(1, 'XX', 0, 6, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'YY', 0, 6, Nono::Config::X, 0, 1))
    hint = Nono::Hint.new(keys)
    assert_equal(3, hint.min_length)

    keys = []
    keys.push(Nono::Key.new(1, 'XX', 0, 6, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)
    assert_equal(1, hint.min_length)
  end

  def test_init_range
    keys = []
    keys.push(Nono::Key.new(1, 'XX', 0, 6, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 6, Nono::Config::X, 0, 1))
    hint = Nono::Hint.new(keys)
    hint.init_range
    key = keys[0]
    assert_equal(0, key.from)
    assert_equal(3, key.to)
    key = keys[1]
    assert_equal(2, key.from)
    assert_equal(6, key.to)
  end

  def test_init_range2
    keys = []
    keys.push(Nono::Key.new(1, 'XX', 0, 6, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'YY', 0, 6, Nono::Config::X, 0, 1))
    hint = Nono::Hint.new(keys)
    hint.init_range
    key = keys[0]
    assert_equal(0, key.from)
    assert_equal(4, key.to)
    key = keys[1]
    assert_equal(1, key.from)
    assert_equal(6, key.to)
  end

end
