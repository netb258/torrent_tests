#Converts Bencoded strings into Ruby structures.
class Bdecoder
  def initialize(encoded_string)
    @bencode = encoded_string.split(//) #Convert to char array.
  end

  def parse_int(start_position = 0)
    start_position += 1 #Bypassing the "i" symbol.
    read_segment(start_position, "e").to_i
  end

  def parse_string(start_position = 0)
    str_size = read_segment(start_position, ":")
    start_position += str_size.length + 1 #Bypassing the ":" symbol.
    str_size = str_size.to_i
    @bencode.slice(start_position, str_size).join
  end

  def parse_list(start_position = 1)
    first_char = @bencode[start_position]
    result = nil

    if first_char == "e" or start_position >= @bencode.length
      return []
    elsif first_char == "i"
      result = parse_int(start_position)
      start_position += get_int_size(result)
    elsif first_char =~ /[0-9]/
      result = parse_string(start_position)
      start_position += get_string_size(result)
    elsif first_char == "l"
      result = parse_list(start_position + 1)
      start_position += get_list_size(result)
    elsif first_char == "d"
      result = parse_hash(start_position)
      start_position += get_hash_size(result)
    end

    return [result] + parse_list(start_position)
  end

  def parse_hash(start_position = 0)
    list = parse_list(start_position + 1)
    keys = list.select.each_with_index { |item, i| i.even? }
    values = list.select.each_with_index { |item, i| i.odd? }
    hash = Hash.new
    keys.each_with_index { |key, i| hash[key] = values[i] }
    hash
  end

  private

  def read_segment(start_position, end_char)
    result = ""

    for c in @bencode[start_position .. @bencode.size]
      break if c == end_char
      result += c
    end

    result
  end

  def get_int_size(the_int)
    the_int.to_s.length + 2 #The "+ 2" is needed to bypass "i" and "e" for ints.
  end

  def get_string_size(the_str)
    str_size = the_str.length
    #The "(str_size.to_s.length + 1)" part is needed to bypass "[num]:" for strings.
    str_size + (str_size.to_s.length + 1) 
  end

  def get_list_size(the_list)
    result = 0

    the_list.each do |item|
      if item.is_a?(Numeric)
        result += get_int_size(item)
      elsif item.is_a?(String)
        result += get_string_size(item)
      elsif item.is_a?(Array)
        result += get_list_size(item)
      elsif item.is_a?(Hash)
        result += get_hash_size(item)
      end
    end

    result + 2 #The "+ 2" is needed to bypass "l" and "e" for lists.
  end

  def get_hash_size(the_hash)
    get_list_size(the_hash.keys + the_hash.values)
  end
end
