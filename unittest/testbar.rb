require 'test/unit'

require 'nono/bar'
require 'nono/cell'
require 'nono/hint'
require 'nono/key'

class TestBar < Test::Unit::TestCase


  def test_attach_hint
    cells = []
    2.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX']))
    end
    cells[0].set_color('XX')
    cells[1].set_color('YY')
    bar = Nono::Bar.new(cells, "dummy")

    keys = []
    3.times do |i|
      keys.push(Nono::Key.new(1, 'XX', 0, 5, Nono::Config::X, 0, i))
    end
    hint = Nono::Hint.new(keys)
    bar.attach_hint(hint)
  end

  def test_solve_by_same_length
    cells = []
    2.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX']))
    end
    bar = Nono::Bar.new(cells, "dummy")

    keys = []
    keys.push(Nono::Key.new(2, 'XX', 0, 1, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)

    bar.attach_hint(hint)
    bar.solve_by_same_length

    assert(bar.fixed?)
    assert_equal('XX', cells[0].color)
    assert_equal('XX', cells[1].color)
  end

  def test_solve_by_larger_half
    cells = []
    3.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX']))
    end
    bar = Nono::Bar.new(cells, "dummy")

    keys = []
    keys.push(Nono::Key.new(2, 'XX', 0, 1, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)

    bar.attach_hint(hint)
    bar.solve_by_larger_half
    assert_equal('XX', cells[1].color)
  end

  def test_solve_by_terminal_fixed1
    cells = []
    3.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX']))
    end
    bar = Nono::Bar.new(cells, "dummy")
    cells.first.set_color('XX')

    keys = []
    keys.push(Nono::Key.new(2, 'XX', 0, 1, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)

    bar.attach_hint(hint)
    bar.solve_by_terminal_fixed
    assert_equal('XX', cells[1].color)
  end

  def test_solve_by_terminal_fixed2
    cells = []
    3.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX']))
    end
    bar = Nono::Bar.new(cells, "dummy")
    cells.last.set_color('XX')

    keys = []
    keys.push(Nono::Key.new(2, 'XX', 0, 2, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)

    bar.attach_hint(hint)
    bar.solve_by_terminal_fixed
    assert_equal('XX', cells[1].color)
  end

  def test_solve_by_terminal_fixed3
    cells = []
    3.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', ' ']))
    end
    cells.last.set_color('XX')
    bar = Nono::Bar.new(cells, "dummy")

    keys = []
    keys.push(Nono::Key.new(1, 'XX', 0, 2, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)

    bar.attach_hint(hint)
    bar.solve_by_terminal_fixed
    assert_equal(Nono::Config::BLANK, cells[1].color)
  end

  def test_solve_by_terminal_fixed4
    cells = []
    10.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', ' ']))
    end
    bar = Nono::Bar.new(cells, "dummy")
    cells.last.set_color('XX')

    keys = []
    keys.push(Nono::Key.new(1, 'XX', 0, 9, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 9, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 9, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 9, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)

    bar.attach_hint(hint)
    assert(!cells[7].fixed?)
    bar.solve_by_terminal_fixed
    assert_equal(Nono::Config::BLANK, cells[8].color)
    assert(!cells[7].fixed?)

    bar.solve_by_terminal_fixed
    assert(!cells[7].fixed?)
    bar.solve_by_terminal_fixed
    assert(!cells[7].fixed?)
  end

  def test_solve_by_terminal_fixed5
    cells = []
    10.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', ' ']))
    end
    bar = Nono::Bar.new(cells, "dummy")
    cells[1].set_color('XX')
    cells.last.set_color('XX')

    keys = []
    keys.push(Nono::Key.new(1, 'XX', 0, 9, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 9, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 9, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 9, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)

    bar.attach_hint(hint)
    assert(!cells[7].fixed?)
    bar.solve_by_terminal_fixed
    assert_equal(Nono::Config::BLANK, cells[8].color)
    assert(!cells[7].fixed?)

    bar.solve_by_terminal_fixed
    assert(!cells[7].fixed?)
    bar.solve_by_terminal_fixed
    assert(!cells[7].fixed?)
  end

  def test_trim_fixed
    cells = []
    10.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', ' ']))
    end
    bar = Nono::Bar.new(cells, "dummy")
    cells[0].set_color('XX')
    cells[1].set_color('XX')
    cells[2].set_blank
    cells[3].set_blank
    cells[4].set_blank
    cells[5].set_color('XX')
    cells[6].set_color('XX')

    keys = []
    keys.push(Nono::Key.new(2, 'XX', 0, 9, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(4, 'XX', 0, 9, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)

    bar.attach_hint(hint)
    bar.trim_fixed

    r = bar.get_range
    assert_equal(5, r.size)
    h = bar.get_rangehint
    assert_equal(1, h.keys.length)
    assert_equal(4, h.first.length)

  end

  def test_trim_fixed
    cells = []
    10.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', ' ']))
    end
    bar = Nono::Bar.new(cells, "dummy")
    cells[0].set_color('XX')
    cells[1].set_blank
    cells[3].set_color('XX')
    cells[5].set_color('XX')
    cells[6].set_color('XX')
    cells[7].set_blank
    cells[8].set_blank
    cells[9].set_color('XX')

    keys = []
    keys.push(Nono::Key.new(1, 'XX', 0, 9, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 9, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 9, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 9, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)

    bar.attach_hint(hint)
    bar.trim_fixed

    r = bar.get_range
    assert_equal(5, r.size)
    h = bar.get_rangehint
    assert_equal(2, h.keys.length)
    assert_equal(2, h.first.length)
    assert_equal(2, h.last.length)
  end

  def test_solve_by_terminal_fixed
    cells = []
    15.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', Nono::Config::BLANK]))
    end
    bar = Nono::Bar.new(cells, "dummy")
    cells[0].set_blank
    cells[1].set_blank
    cells[5].set_color('XX')
    (8..12).each do |i|
      cells[i].set_color('XX')
    end
    cells[13].set_blank
    cells[14].set_blank

    keys = []
    keys.push(Nono::Key.new(2, 'XX', 0, 14, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(5, 'XX', 0, 14, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)

    bar.attach_hint(hint)
    bar.nallow_range
    bar.solve_by_terminal_fixed
    assert_equal(Nono::Config::BLANK, cells[7].color)
  end

  def test_solve_by_recalc_range
    cells = []
    20.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', Nono::Config::BLANK]))
    end
    bar = Nono::Bar.new(cells, "dummy")
    cells[0].set_blank
    cells[1].set_blank
    cells[2].set_color('XX')
    cells[3].set_color('XX')
    cells[4].set_blank
    cells[7].set_blank
    cells[8].set_blank
    (9..14).each do |i|
      cells[i].set_color('XX')
    end
    cells[15].set_blank
    cells[16].set_blank
    cells[17].set_blank

    keys = []
    keys.push(Nono::Key.new(2, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(6, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 19, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)

    bar.attach_hint(hint)
    bar.nallow_range
    assert_equal(9, bar.get_rangehint.keys[1].to)
    assert_equal(13, bar.get_rangehint.keys[2].from)
    bar.recalc_range
    assert_equal(13, bar.settable_index_by_key(bar.get_rangehint.keys[2]))
    assert_equal(13, bar.get_rangehint.keys[2].from)

    bar.solve_by_larger_half
    assert_equal('XX', cells[18].color)
    assert_equal('XX', cells[19].color)

  end

  def test_solve_by_recalc_range2
    cells = []
    15.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', ' ']))
    end
    bar = Nono::Bar.new(cells, "dummy")
    cells[5].set_blank
    cells[6].set_color('XX')
    cells[7].set_color('XX')
    cells[8].set_color('XX')
    cells[9].set_blank

    keys = []
    keys.push(Nono::Key.new(2, 'XX', 0, 14, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(3, 'XX', 0, 14, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 14, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 14, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 14, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)
    bar.attach_hint(hint)
    bar.nallow_range
    assert_equal(10, bar.get_rangehint.keys[2].from)
    assert_equal(12, bar.get_rangehint.keys[3].from)
    assert_equal(14, bar.get_rangehint.keys[4].from)
  end

  def test_solve_by_recalc_range3
    cells = []
    15.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', ' ']))
    end
    bar = Nono::Bar.new(cells, "dummy")
    cells[5].set_color('XX')
    cells[7].set_blank

    keys = []
    keys.push(Nono::Key.new(6, 'XX', 0, 14, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 14, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 14, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)
    bar.attach_hint(hint)
    bar.nallow_range
    assert_equal(6, bar.get_rangehint.keys[0].to)
  end


  def test_recalc_range_by_fixed_cell
    cells = []
    20.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', ' ']))
    end
    bar = Nono::Bar.new(cells, "dummy")
    cells[0].set_blank
    cells[2].set_color('XX')
    cells[8].set_color('XX')
    cells[10].set_blank
    cells[11].set_blank
    (12..19).each do |i|
      cells[i].set_color('XX')
    end

    keys = []
    keys.push(Nono::Key.new(2, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(8, 'XX', 0, 19, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)

    bar.attach_hint(hint)
    bar.nallow_range
    assert_equal(0, bar.get_rangehint.keys[0].from)
    assert_equal(2, bar.get_rangehint.keys[0].to)
    assert_equal(6, bar.get_rangehint.keys[1].from)
    assert_equal(8, bar.get_rangehint.keys[1].to)
  end

  def test_nallow_range
    cells = []
    15.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', ' ']))
    end
    bar = Nono::Bar.new(cells, "dummy")

    (2..3).each do |i|
      cells[i].set_color('XX')
    end
    (6..7).each do |i|
      cells[i].set_color('XX')
    end
    (11..12).each do |i|
      cells[i].set_color('XX')
    end

    keys = []
    keys.push(Nono::Key.new(4, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(3, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(4, 'XX', 0, 19, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)
    bar.attach_hint(hint)
    bar.nallow_range
    assert_equal(4, bar.get_rangehint.keys[0].to)
  end

  def test_solve_by_one_key_includable_colored_range
    cells = []
    10.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', Nono::Config::BLANK]))
    end
    bar = Nono::Bar.new(cells, "dummy")

    cells[6].set_color('XX')

    keys = []
    keys.push(Nono::Key.new(2, 'XX', 0, 9, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 9, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 9, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 9, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)
    bar.attach_hint(hint)
    bar.nallow_range
    bar.solve_by_one_key_includable_colored_range
    assert_equal(Nono::Config::BLANK, cells[5].color)
    assert_equal(Nono::Config::BLANK, cells[7].color)
    bar.nallow_range
    assert_equal(2, bar.get_rangehint.keys[0].to)
  end

  def test_nallow_range2
    cells = []
    20.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', ' ']))
    end
    bar = Nono::Bar.new(cells, "dummy")
    (1..3).each do |i|
      cells[i].set_blank
    end
    (4..5).each do |i|
      cells[i].set_color('XX')
    end
    cells[6].set_blank
    cells[7].set_color('XX')
    cells[8].set_blank
    cells[9].set_color('XX')

    (10..13).each do |i|
      cells[i].set_blank
    end
    cells[14].set_color('XX')
    (15..16).each do |i|
      cells[i].set_blank
    end
    cells[18].set_blank
    cells[19].set_color('XX')

    keys = []
    keys.push(Nono::Key.new(1, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 19, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)

    bar.attach_hint(hint)
    bar.nallow_range

    assert_equal(0, bar.get_rangehint.keys[0].from)
    assert_equal(0, bar.get_rangehint.keys[0].to)

  end

  def test_solve_by_includable_same_length_key
    cells = []
    20.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', Nono::Config::BLANK]))
    end
    bar = Nono::Bar.new(cells, "dummy")
    (2..3).each do |i|
      cells[i].set_blank
    end
    cells[6].set_color('XX')
    cells[9].set_color('XX')
    cells[15].set_color('XX')
    (18..19).each do |i|
      cells[i].set_blank
    end
    keys = []
    keys.push(Nono::Key.new(2, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 19, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)
    bar.attach_hint(hint)
    bar.nallow_range
    bar.solve_by_includable_same_length_key

    assert_equal(Nono::Config::BLANK, cells[14].color)
    assert_equal(Nono::Config::BLANK, cells[16].color)
    
  end

  def test_solve_by_includable_same_length_key2
    cells = []
    10.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', Nono::Config::BLANK]))
    end
    bar = Nono::Bar.new(cells, "dummy")

    (3..5).each do |i|
      cells[i].set_color('XX')
    end
    keys = []
    keys.push(Nono::Key.new(9, 'XX', 0, 19, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)
    bar.attach_hint(hint)
    bar.nallow_range
    bar.solve_by_includable_same_length_key
    assert(!cells[2].fixed?)
    assert(!cells[6].fixed?)
  end

  def test_nallow_range4

    cells = []
    20.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', ' ']))
    end
    bar = Nono::Bar.new(cells, "dummy")
    
    cells[9].set_color('XX')
    cells[15].set_color('XX')
    (18..19).each do |i|
      cells[i].set_blank
    end

    keys = []
    keys.push(Nono::Key.new(2, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 19, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)

    bar.attach_hint(hint)
#    bar.dump_info
    bar.nallow_range
#    bar.dump_info
  end

  def test_solve_by_side_cell_fixed
    cells = []
    20.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', Nono::Config::BLANK]))
    end
    bar = Nono::Bar.new(cells, "dummy")

    cells[0].set_blank
    (1..2).each do |i|
      cells[i].set_color('XX')
    end
    (3..8).each do |i|
      cells[i].set_blank
    end
    cells[11].set_blank
    cells[12].set_color('XX')

    keys = []
    keys.push(Nono::Key.new(2, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 19, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)
    bar.attach_hint(hint)
    bar.nallow_range
    bar.solve_by_side_cell_fixed
    assert_equal('XX', cells[13].color)
    assert(!cells[14].fixed?)
  end

  def test_solve_by_inner_terminal_unreached
    cells = []
    20.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', Nono::Config::BLANK]))
    end
    bar = Nono::Bar.new(cells, "dummy")
    (2..3).each do |i|
      cells[i].set_blank
    end
    cells[6].set_color('XX')
    cells[9].set_color('XX')
    cells[14].set_blank
    cells[15].set_color('XX')
    cells[16].set_blank
    (18..19).each do |i|
      cells[i].set_blank
    end
    keys = []
    keys.push(Nono::Key.new(2, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 19, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 19, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)
    bar.attach_hint(hint)
    bar.nallow_range
    ranges = bar.ranges_split_by_blank
    assert_equal(4, ranges.size)
    assert_equal(0, ranges[0].first)
    assert_equal(4, ranges[1].first)
    assert_equal(15, ranges[2].first)
    assert_equal(17, ranges[3].first)
    bar.solve_by_inner_terminal_unreached
    assert_equal(Nono::Config::BLANK, cells[4].color)
    
  end

  def test_solve_by_one_unfixed_cell
    cells = []
    10.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', Nono::Config::BLANK]))
    end
    bar = Nono::Bar.new(cells, "dummy")
    cells[3].set_color('XX')
    cells[5].set_color('XX')
    keys = []
    keys.push(Nono::Key.new(2, 'XX', 0, 9, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 9, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)
    bar.attach_hint(hint)
    bar.nallow_range
    bar.solve_by_one_unfixed_cell
    assert_equal(Nono::Config::BLANK, cells[4].color)
  end

  def test_solve_by_one_unfixed_cell2
    cells = []
    10.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', 'YY', Nono::Config::BLANK]))
    end
    bar = Nono::Bar.new(cells, "dummy")
    cells[7].set_color('XX')
    cells[9].set_color('XX')
    keys = []
    keys.push(Nono::Key.new(1, 'YY', 0, 9, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 9, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'YY', 0, 9, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 9, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)
    bar.attach_hint(hint)
    bar.nallow_range
    bar.solve_by_one_unfixed_cell
    assert_equal(2, cells[8].colors.size)
    assert(cells[8].colors.include?('YY'))
    assert(!cells[8].colors.include?('XX'))
  end

  def test_consist
    cells = []
    10.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', 'YY', Nono::Config::BLANK]))
    end
    bar = Nono::Bar.new(cells, "dummy")
    cells[0].set_color('XX')
    cells[1].set_blank
    cells[2].set_blank

    keys = []
    keys.push(Nono::Key.new(2, 'XX', 0, 9, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 9, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)
    bar.attach_hint(hint)
    assert(!bar.consist?)
  end

  #
  # 2 5 2 1  ______??XX????????XXXX??__??????????????????________XXXX__XX
  #  =>
  # 2 5 2 1  ______??XX????????XXXX??____________________________XXXX__XX
  #
  def test_solve_by_key_range
    cells = []
    30.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', Nono::Config::BLANK]))
    end
    bar = Nono::Bar.new(cells, "dummy")
    blank(cells, 0, 2)
    cells[4].set_color('XX')
    col(cells, 9, 10)
    blank(cells, 12,12)
    blank(cells, 22,25)
    col(cells, 26, 27)
    blank(cells, 28, 28)
    col(cells, 29, 29)

    keys = []
    keys.push(Nono::Key.new(2, 'XX', 0, 29, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(5, 'XX', 0, 29, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 29, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 29, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)
    bar.attach_hint(hint)
    bar.nallow_range
    bar.solve_by_key_range
    (14..21).each do |i|
      assert_equal(Nono::Config::BLANK, cells[i].color)
    end
  end

  #
  # 2 2 1 4 2  ____??????????XX??____??__XXXXXXXX______________________XXXX
  #  =>
  # 2 2 1 4 2  ____??????????XX??____XX__XXXXXXXX______________________XXXX
  #
  def test_recalc_key_range_by_side_fixed_cell
    cells = []
    30.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', Nono::Config::BLANK]))
    end
    bar = Nono::Bar.new(cells, "dummy")
    blank(cells, 0, 1)
    col(cells, 7, 7)
    blank(cells, 9, 10)
    blank(cells, 12,12)
    col(cells, 13, 16)
    blank(cells, 17, 27)
    col(cells, 28, 29)

    keys = []
    keys.push(Nono::Key.new(2, 'XX', 0, 29, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 29, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(1, 'XX', 0, 29, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(4, 'XX', 0, 29, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(2, 'XX', 0, 29, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)
    bar.attach_hint(hint)
    bar.nallow_range
    bar.recalc_key_range_by_side_fixed_cell
    assert_equal(9, bar.get_rangehint.keys[2].from)
    bar.recalc_key_by_terminal_blank_cell
    assert(!cells[11].fixed?)
    bar.solve_by_larger_half
    assert(cells[11].fixed?)
    assert_equal('XX', cells[11].color)
  end

  #
  # 1  5    ??????????????????????????????XX??XX____??????????????______
  #   =>
  # 1  5    ??????????????????????????XXXXXXXXXX________________________
  #
  def test_recalc_terminal_key_range
    cells = []
    30.times do |i|
      cells.push(Nono::Cell.new(i, 0, ['XX', Nono::Config::BLANK]))
    end
    bar = Nono::Bar.new(cells, "dummy")
    col(cells, 15, 15)
    col(cells, 17, 17)
    blank(cells, 18, 19)
    blank(cells, 27, 29)

    keys = []
    keys.push(Nono::Key.new(1, 'XX', 0, 29, Nono::Config::X, 0, 0))
    keys.push(Nono::Key.new(5, 'XX', 0, 29, Nono::Config::X, 0, 0))
    hint = Nono::Hint.new(keys)
    bar.attach_hint(hint)
    bar.nallow_range
    bar.recalc_terminal_key_range
    assert_equal(15, bar.get_rangehint.keys[0].to)
    assert_equal(13, bar.get_rangehint.keys[1].from)
    bar.solve_by_larger_half
    bar.dump_info

  end

  def col(cells, from, to, col='XX')
    (from .. to).each do |i|
      cells[i].set_color(col)
    end
  end

  def blank(cells, from, to)
    (from .. to).each do |i|
      cells[i].set_blank
    end
  end
    

end
