# encoding:utf-8
require 'open-uri'
require 'nokogiri'
require 'date'
require_relative './yahoo_api.rb'
require_relative './auction_list_items.rb'
require_relative './item.rb'
require_relative './xml_parse_sets.rb'



class CategoryItems < AuctionListItems
  include Enumerable
  
  Category_tags = {

  }

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
    items_xml_list = get_items_xml(url)
    items_xml_list.each do |perxml|
      item = Item.new
      item.get_tags(perxml,Common_tags.merge(Category_tags))

      item.info_when_get[:from_category] = {}
      item.info_when_get[:from_category][:category_id] = @category_id
      item.info_when_get[:from_category][:get_date] = DateTime.now

      #pp item

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




