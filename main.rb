# encoding:utf-8
require 'pp'
require 'pry'
require './category_items.rb'
require './item.rb'
require './yahoo_api.rb'


TP13_ID = 2084307189

def get_key_from_file(filename)
  # utf-8のtxtファイルの一行目をkeyとして読む
  s = File.read(filename,encoding: Encoding::UTF_8)
  s.chomp
end


apikey = get_key_from_file "key.txt"
YahooAPI.set_api_key(apikey)


cat = CategoryItems.new(TP13_ID,{sort_by: :current_price, order: :desc})

#cat.get_all

cat.take(110).each do |a|
  puts "#{a.auction_id} | #{a.title} \\#{a.current_price}"
end
