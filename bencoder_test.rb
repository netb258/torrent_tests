require "./bencoder.rb"
require "test/unit"

class TestBencoder < Test::Unit::TestCase
  def test_integer_encoding
    assert_equal(Bencoder.encode_int(3), "i3e")
    assert_equal(Bencoder.encode_int(100), "i100e")
    assert_equal(Bencoder.encode_int("99"), "i99e")
  end

  def test_string_encoding
    assert_equal(Bencoder.encode_string("aaa"), "3:aaa")
    assert_equal(Bencoder.encode_string("something"), "9:something")
    assert_equal(Bencoder.encode_string("something123"), "12:something123")
  end

  def test_list_encoding
    assert_equal(Bencoder.encode_list(["spam", "eggss"]), "l4:spam5:eggsse")
    assert_equal(Bencoder.encode_list(["a", 1]), "l1:ai1ee")
    assert_equal(Bencoder.encode_list([["spam"], "eggss"]), "ll4:spame5:eggsse")
    assert_equal(Bencoder.encode_list([12, {"spam" => "eggss"}]), "li12ed4:spam5:eggssee")
  end

  def test_hash_encoding
    assert_equal(Bencoder.encode_hash({"cow" => "moo", "spam" => "eggs"}), "d3:cow3:moo4:spam4:eggse")
    assert_equal(Bencoder.encode_hash({"spam" => ["a", "b"]}), "d4:spaml1:a1:bee")
  end
end
