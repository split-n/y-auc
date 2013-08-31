# encoding:utf-8
require 'date'
require './yahoo_api.rb'

class Item
  include YahooAPI

  attr_accessor :auction_id, :title, :seller_id, :item_url, :image_url, :end_time, :current_price, :buy_price, :bids,:category_id, :get_from

  def initialize
      
  end

  def valid?
    return false if @auction_id == "" || !@auction_id.is_a?(String)
    return false if @title == "" || !@title.is_a?(String)
    return false if @seller_id == "" || !@seller_id.is_a?(String)
    return false if @item_url == "" || !item_url.is_a?(String)
    return false if @image_url == "" || !@image_url.is_a?(String)
    return false if !@end_time.is_a?(DateTime)
    return false if !@current_price.is_a?(Integer)

    if @buy_price == nil
      return true
    elsif @buy_price.is_a?(Integer) 
      return true
    else
      false
    end
        
    return false if !@bids.is_a?(Integer)
    return true
  end

  def price_lower_than(price)
    return (self.current_price < price)
  end  

  def price_higherer_than(price)
    return (self.current_price > price)
  end  

  def update

  end

  private
  def get_my_info
    
  end

end
