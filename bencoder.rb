#Converts Ruby integers, strings, arrays and hashes, into Bencoded strings.
class Bencoder
  def encode_int(int)
    int = int.to_i #Make sure an integer is passed.
    "i" + int.to_s + "e"
  end

  def encode_string(str)
    str = str.to_s #Make sure a string is passed.
    str.length.to_s + ":" + str
  end

  def encode_list(list)
    result = "l"

    list.each do |item|
      if item.is_a?(Numeric)
        result += encode_int(item)
      elsif item.is_a?(String)
        result += encode_string(item)
      elsif item.is_a?(Array)
        result += encode_list(item)
      elsif item.is_a?(Hash)
        result += encode_hash(item)
      end
    end

    result + "e"
  end

  def encode_hash(hash)
    result = []

    hash.each do |key, value|
      result.push(key)
      result.push(value)
    end

    result = encode_list(result)
    result[0] = "d"
    result
  end
end
