# encoding:utf-8
require 'open-uri'
require 'nokogiri'
require 'pp'
require 'pry'
require 'date'

API_KEY = ''

class Item

  attr_accessor :auction_id, :title, :seller_id, :item_url, :image_url, :end_time, :current_price, :buy_price, :bids 

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



  

end

class CategoryItems

  def initialize(category_id)
    @category_id = category_id
    @items = []
  end

  def create_request_url()
    minimum_url = "http://auctions.yahooapis.jp/AuctionWebService/V2/categoryLeaf?" + 
    "appid=#{API_KEY}" + 
    "&category=#{@category_id.to_s}"
    minimum_url
  end

  def get
    get_item_list(create_request_url)
  end

  def get_item_list(url)
    
    xmlfile = open(url)
    doc = Nokogiri::XML(xmlfile)
    doc.search('Item').each do |elem|
      item = Item.new
      item.auction_id = elem.at('AuctionID').inner_text
      item.title = elem.at('Title').inner_text
      item.seller_id = elem.at('Seller/Id').inner_text
      item.item_url = elem.at('AuctionItemUrl').inner_text
      item.image_url = elem.at('Image').inner_text
      item.end_time = DateTime.parse(elem.at('EndTime').inner_text)
      item.current_price = elem.at('CurrentPrice').inner_text.to_i
      if elem.at('BidOrBuy') 
        buyprice = elem.at('BidOrBuy').inner_text.to_i
      else
        buyprice = nil
      end
      item.buy_price = buyprice
      item.bids = elem.at('Bids').inner_text.to_i

      if item.valid?
        @items << item
      else
        # for debug
        puts "::: validation error :::"
        PP.pp(item,STDERR)
      end
    end
    return @items
  end

  attr_reader :category_id

end

cat = CategoryItems.new(2084193586)
pp cat.get

