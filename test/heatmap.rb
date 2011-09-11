#encoding: utf-8
require File.join(File.expand_path(File.dirname(__FILE__)),"/../lib/heatmap")
require "test/unit"
class TestHeatmap < Test::Unit::TestCase
  def test_chunks
    data = ["I", "I", "S", "C", "H", "M", "H", "M", "D", "E", "H", "R", "T", "D", "P", "K", "T", "E", "P", "R", "E", "B", "H", "T", "F", "P", "F", "L", "C", "E", "A", "D", "J", "L", "M", "B", "P", "F", "G", "K", "T", "R", "E", "F", "O", "J", "F", "J", "I", "O", "I", "H", "B", "E", "D", "J", "S", "Q", "A", "E", "N", "P", "D", "Q", "M", "H", "T", "T", "G", "T", "P", "L", "E", "G", "I", "O", "J", "O", "K", "A", "L", "N", "H", "B", "O", "P", "O", "I", "D", "F", "L", "B", "P", "M", "R", "G", "E", "B", "R", "M", "T", "S", "S", "N", "G", "G", "B", "A", "J", "H", "A", "M", "S", "J", "J", "T", "J", "D", "E", "K", "E", "M", "K", "K", "P", "B", "J", "G", "B", "S", "G", "P", "L", "T", "Q", "L", "E", "M", "F", "N", "P", "I", "N", "D", "I", "P", "N", "P", "H", "D", "E", "D", "J", "B", "G", "G", "E", "N", "I", "B"]
    hm = Heatmap.new(data.length,1);
    data.each.with_index{|letter,pos|
      hm.add_entry(pos,letter) if ["A","E","I","O","U"].index(letter)
    }
    assert_equal([[49, ["I", "O", "I"]], [58, ["A", "E"]], [157, ["E", "I"]], [29, ["E", "A"]]], hm.hot_chunks(3))
  end
  def test_zones
    data = "A AA".chars.to_a
    hm = Heatmap.new(data.length,1,false);
    data.each.with_index{|letter,pos|
      hm.add_entry(pos,letter) if letter != " "
    }
    assert_equal([{:start => 2, :end =>4, :entries => ["A","A"]}, 
                 {:start => 0, :end =>1, :entries => ["A"]}, ], hm.hot_areas(2))

    data = "AAAA".chars.to_a
    hm = Heatmap.new(data.length,1,false);
    data.each.with_index{|letter,pos|
      hm.add_entry(pos,letter) if letter != " "
    }
    assert_equal([{:start => 2, :end =>4, :entries => ["A","A"]}, 
                 {:start => 0, :end =>2, :entries => ["A","A"]}, ], hm.hot_areas(2,2))

  end

end
