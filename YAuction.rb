# encoding:utf-8
require './category_items.rb'
require './item.rb'

class YAuction

  def self.testrun(apikey)
    CategoryItems.set_api_key(apikey)

    cat = CategoryItems.new(2084193586,{min_price: 100, sort_by: :end_time, order: :desc})
    cat.take(75).each_with_index do |val,i|
      p i
    end

    puts "================="

    cat.take(70).each_with_index do |val,i|
      p i
    end

















  end


end