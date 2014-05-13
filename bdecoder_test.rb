require "./bdecoder.rb"
require "test/unit"

class TestBdecoder < Test::Unit::TestCase
  def test_int_parsing
    parser = Bdecoder.new("i3e")
    assert_equal(3, parser.parse_int)

    #Ignores everything after "e".
    parser = Bdecoder.new("i99eabc")
    assert_equal(99, parser.parse_int(0))

    #Returns 0 if an invalid string is provided.
    parser = Bdecoder.new("abc")
    assert_equal(0, parser.parse_int(0))
  end

  def test_string_parsing
    parser = Bdecoder.new("3:aaa")
    assert_equal("aaa", parser.parse_string)

    parser = Bdecoder.new("9:something")
    assert_equal("something", parser.parse_string(0))
  end

  def test_list_parsing
    parser = Bdecoder.new("l4:spam5:eggsse")
    assert_equal(["spam", "eggss"], parser.parse_list)

    parser = Bdecoder.new("l1:ai1ee")
    assert_equal(["a", 1], parser.parse_list)

    parser = Bdecoder.new("ll4:spame5:eggsse")
    assert_equal([["spam"], "eggss"], parser.parse_list(1))

    #A list with a hash inside.
    parser = Bdecoder.new("li12ed4:spam5:eggssee")
    assert_equal([12, {"spam" => "eggss"}], parser.parse_list(1))
  end

  def test_hash_parsing
    parser = Bdecoder.new("d3:cow3:moo4:spam4:eggse")
    assert_equal({"cow" => "moo", "spam" => "eggs"} , parser.parse_hash)

    #A hash with a list inside.
    parser = Bdecoder.new("d4:spaml1:a1:bee")
    assert_equal({"spam" => ["a", "b"]}  , parser.parse_hash(0))
  end
end
