# encoding:utf-8
require 'pp'
require 'pry'
require './category_items.rb'
require './item.rb'
require './yahoo_api.rb'


TP13 = 2084307189

def get_key_from_file(filename)
  s = File.read(filename,encoding: Encoding::UTF_8)
  s.chomp
end

def testrun(apikey)
  YahooAPI.set_api_key(apikey)

  cat = CategoryItems.new(TP13,{sort_by: :current_price, order: :desc})

  #cat.get_all

  caty.take(110).each do |a|
    puts "#{a.auction_id}-#{a.title}-#{a.current_price}"
  end
end
 key = get_key_from_file "key.txt"
testrun(key)
