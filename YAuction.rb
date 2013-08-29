# encoding:utf-8
require './category_items.rb'
require './item.rb'



def get_key_from_file(filename)
  s = File.read(filename,encoding: Encoding::UTF_8)
  s.chomp
end

def testrun(apikey)
  CategoryItems.set_api_key(apikey)

  cat = CategoryItems.new(2084039759,{min_price: 100, sort_by: :end_time, order: :desc})

  cat.each do |a|
    p a.title
  end
end
 key = get_key_from_file "key.txt"
testrun(key)
