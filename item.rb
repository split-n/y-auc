# encoding:utf-8
require 'date'
require './yahoo_api.rb'

class Item
  include YahooAPI

  attr_accessor :attrs,:get_info

  def initialize
     @attrs = {}
     # attrs には原則元xmlのタグをsnake_caseにしたものを使う
     @get_info = {} 
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


  def update
    p create_request_url
  end

  private

  def create_request_url
    url = 'http://auctions.yahooapis.jp/AuctionWebService/V2/auctionItem?' +
    "appid=#{@@api_key}"+ 
    "&auctionID=#{self.auction_id}"

    url
  end

  def get_my_info(url)
    xmlfile = open(url)
    doc = Nokogiri::XML(xmlfile)
    doc.search('Item').each do |elem|

    
    end
  end

end
