# encoding:utf-8
require 'open-uri'
require 'nokogiri'
require 'pp'
require 'pry'
require 'date'


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

  def price_lower_than(price)
    return (self.current_price < price)
  end  

  def price_higherer_than(price)
    return (self.current_price > price)
  end  

end

class CategoryItems
  include Enumerable

  attr_reader :category_id, :items

  def self.set_api_key(api_key)
    @@api_key = api_key
  end

  def initialize(category_id)
    raise unless @@api_key
    @category_id = category_id
    @items = []
  end

  def create_request_url(args = {})
    url = "http://auctions.yahooapis.jp/AuctionWebService/V2/categoryLeaf?" + 
    "appid=#{@@api_key}" + 
    "&category=#{@category_id.to_s}"

    page = args[:page] if args[:page].is_a?(Integer)

    sort = case args[:sort_by]
      when :end_time
        "end"
      when :has_image
        "img"
      when :bids
        "bids"
      when :current_price
        "cbids"
      when :buy_price
        "bidorbuy"
      when :affiliate
        "affilate"
      else 
        nil
      end

    order = case args[:order]
      when :desc
        "d"
      when :asc 
        "a"
      else 
        nil
      end

    store = case args[:store]
      when :all
        0
      when :store
        1
      when :normal
        2
      else 
        nil
      end

    item_status = case args[:item_status]
      when :all
        0
      when :new
        1
      when :used
        2
      else 
        nil
      end

    aucmin_bidorbuy_price = args[:min_buy_price] if args[:min_buy_price].is_a?(Integer)
    aucmax_bidorbuy_price = args[:max_buy_price] if args[:max_buy_price].is_a?(Integer)

    aucmaxprice = args[:max_price] if args[:max_price].is_a?(Integer)
    aucminprice = args[:min_price] if args[:min_price].is_a?(Integer)

    buynow = case args[:buynow]
      when true
        1
      when false
        2
      else 
        nil
      end

    %w(buynow aucmaxprice aucminprice page sort order store item_status aucmin_bidorbuy_price aucmax_bidorbuy_price).each do |a|
      url += "&#{a}=#{eval(a)}" if eval(a)
    end




    return url
  end

  def get_first_page
    get_item_list(create_request_url)
  end

  def get(args = {})
    url = create_request_url(args) 
    p url
    get_item_list(url)
    @items
  end

  def each
    items_readed_pos = 0
    @items.each do |item|
      yield(item)
      items_readed_pos += 1
    end
  end

  private
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
  end

  
end




