# encoding:utf-8
require 'pp'
require 'pry'
require './category_items.rb'
require './search_items.rb'
require './item.rb'
require './yahoo_api.rb'


TP13_CATID = 2084307189

def get_key_from_file(filename)
  # utf-8のtxtファイルの一行目をkeyとして読む
  s = File.read(filename,encoding: Encoding::UTF_8)
  s.chomp
end


apikey = get_key_from_file "key.txt"
YahooAPI.set_api_key(apikey)

# example for usage
search1 = SearchItems.new("MacBook",{sort_by: :current_price,order: :desc})
category1 = CategoryItems.new(TP13_CATID,{
  max_buy_price:40000,sort_by: :end_time,order: :desc})


search1.take(20).each do |a|
  puts "#{a.auction_id} | #{a.title} \\#{a.current_price}"
end

puts "=============="

category1.take(30).each do |a|
  puts "#{a.title} | #{a.current_price} | #{a.end_time}"
end
