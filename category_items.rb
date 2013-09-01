# encoding:utf-8
require 'open-uri'
require 'nokogiri'
require 'date'
require './yahoo_api.rb'
require './list_items.rb'



class CategoryItems < ListItems
  include Enumerable

  attr_reader :category_id

  def initialize(category_id,opt={})
    super(opt)
    @category_id = category_id
  end


  private

  def create_request_url(page)
    url = "http://auctions.yahooapis.jp/AuctionWebService/V2/categoryLeaf?" + 
    "appid=#{@@api_key}" + 
    "&category=#{@category_id.to_s}" + 
    "&page=#{page}"

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

    %w(buynow aucmaxprice aucminprice sort order store item_status aucmin_bidorbuy_price aucmax_bidorbuy_price).each do |a|
      url += "&#{a}=#{eval(a)}" if eval(a)
    end




    return url
  end

  


  def get_item_list(url)
    items_list = {}
    xmlfile = open(url)
    doc = Nokogiri::XML(xmlfile)
    doc.search('Item').each do |elem|
      item = Item.new
      item.attrs[:auction_id] = elem.at('AuctionID').inner_text
      item.attrs[:seller_id] = elem.at('Seller/Id').inner_text
      item.attrs[:auction_item_url] = elem.at('AuctionItemUrl').inner_text
      item.attrs[:image] = elem.at('Image').inner_text
      item.attrs[:end_time] = DateTime.parse(elem.at('EndTime').inner_text)
      item.attrs[:current_price] = elem.at('CurrentPrice').inner_text.to_i

      item.attrs[:bid_or_buy] = elem.at('BidOrBuy').inner_text.to_i if elem.at('BidOrBuy') 
      item.attrs[:bids] = elem.at('Bids').inner_text.to_i

      item.get_info[:from_category] = {}
      item.get_info[:from_category][:category_id] = @category_id
      item.get_info[:from_category][:get_date] = DateTime.now


      if item.valid?
        items_list[item.auction_id] = item
      else
        # for debug
        PP.pp(item,STDERR)
      end
    end
    return items_list
  end
  
end




