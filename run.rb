# encoding:utf-8
require './category_items.rb'
require './item.rb'

class YAuction

  def self.testrun(apikey)
    CategoryItems.set_api_key(apikey)

    cat = CategoryItems.new(2084193586)
    pp cat.get(min_price: 10000, sort_by: :end_time, order: :desc,buynow: false)





















  end


end