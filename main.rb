# encoding:utf-8
require 'pp'
require 'pry'
require_relative './core/category_items.rb'
require_relative './core/search_items.rb'
require_relative './core/yahoo_api.rb'
require 'pry-byebug'


TP13_ID = 2084307189

def get_key_from_file(filename)
  # utf-8のtxtファイルの一行目をkeyとして読む
  s = File.read(filename,encoding: Encoding::UTF_8)
  s.chomp
end


apikey = get_key_from_file "key.txt"
YahooAPI.set_api_key(apikey)

search = SearchItems.new("ThinkPad",{sort_by: :current_price,order: :desc})

item = search.first
pp item 

item.update!

pp item
