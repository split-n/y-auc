# encoding:utf-8
require 'date'
require './yahoo_api.rb'
require 'nokogiri'

class Item
  include YahooAPI
  TAGS_TABLE = {
      auction_id: ['AuctionID',"String"],
      seller_id: ['Seller/Id',"String"],
      auction_item_url: ['AuctionItemUrl',"String"],
      image: ['Image',"String"],
      end_time: ['EndTime',"DateTime"],
      current_price: ['CurrentPrice',"Integer"],
      bid_or_buy: ['BidOrBuy',"Integer"],
      bids: ['Bids',"Integer"],
      category_id: ['CategoryId',"Integer"],
      title: ['Title',"String"]
    }

  attr_accessor :attrs,:info_when_get

  def initialize
     @attrs = {}
     # attrs には原則元xmlのタグをsnake_caseにしたものを使う
     @info_when_get= {} 
  end

  def valid?
    [:title,:seller_id,:auction_item_url,:auction_id].each do |sym|
      return false if @attrs[sym] == "" || !@attrs[sym].is_a?(String)
    end
    
    return false if !@attrs[:end_time].is_a?(DateTime)

    [:current_price,:bids].each do |sym|
      return false if !@attrs[sym].is_a?(Integer)
    end

    return true
  end
  def get_tags(elem,require_tags)
    # 1つのitemに相当する部分のxmlを渡す
    require_tags.each do |key|
      node_name = TAGS_TABLE[key][0]
      type = TAGS_TABLE[key][1]
      raise unless node_name
      node = elem.at(node_name)
      if node #nilの際は未代入のまま
        innertext = node.inner_text
        self.attrs[key] = case type
        when "String"
          innertext
        when "DateTime"
          DateTime.parse(innertext) 
        when "Integer"
          innertext.to_i
        else 
          raise
        end
      end
    end
    self
  end


  def update

  end

  private
  def get_my_info
    
  end

end
