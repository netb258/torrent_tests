require "digest/sha1"
require "net/http"
require "base64"
require "./bdecoder.rb"
require "./bencoder.rb"

filename = ARGV[0]
bencode = File.open(filename, "rb") { |f| f.read }
hash = Bdecoder.new(bencode).parse_hash

base_url = hash["announce"]

#Prefer the announce list, if it is provided in the file.
if hash["announce-list"] != nil
  base_url = hash["announce-list"][0][0]
end

#Get the 20 byte SHA1 of the info hash with SHA1.digest. Also, it needs to be URL encoded with URI::encode.
#Note that hash["info"] is currently a Ruby hash, need to convert it to bencode with Bencoder.new.encode_hash.
info_hash = Digest::SHA1.digest( Bencoder.new.encode_hash(hash["info"]) )
info_hash = URI::encode(info_hash)

#Generate a random uid with a simple algorithm.
peer_id = (("a".."z").to_a() + ("A".."Z").to_a()).shuffle()[0..19].join()
event = "started"
port = "8080"

params = "info_hash=" + info_hash + "&peer_id=" + peer_id + "&event=" + event + "&port=" + port

if base_url.include?("?")
  base_url += "&" + params
else
  base_url += "?" + params
end

parsed_url = URI.parse(base_url)
result = Net::HTTP.get(parsed_url)
puts result
