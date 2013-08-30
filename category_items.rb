# encoding:utf-8
require 'open-uri'
require 'nokogiri'
require 'date'
require './yahoo_api.rb'
require './list_items.rb'



class CategoryItems < ListItems
  include Enumerable
  include YahooAPI

  attr_reader :category_id, :items, :options

  def initialize(category_id,opt={})
    super(opt)
    @category_id = category_id
  end


  private

  def create_request_url(page)
    url = "http://auctions.yahooapis.jp/AuctionWebService/V2/categoryLeaf?" + 
    "appid=#{@@api_key}" + 
    "&category=#{@category_id.to_s}"

    # page = args[:page] if args[:page].is_a?(Integer)
    # pageはオプションからの指定が有効、外部からは触らない
    args = @options

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

  


  def get_item_list(url)
    items_on_list = {}
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

      item.get_from_category = @category_id

      if item.valid?
        items_on_list[item.auction_id] = item
      else
        # for debug
        puts "::: validation error :::"
        PP.pp(item,STDERR)
      end
    end
    return items_on_list
  end
  
end




