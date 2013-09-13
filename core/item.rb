# encoding:utf-8
require 'date'
require 'nokogiri'
require 'open-uri'
require_relative './yahoo_api.rb'
require_relative './xml_parse_sets.rb'

include XmlParseSets

class Item
  include YahooAPI

  Item_tags = {
    title: ['Title',Tag_by_str],
    seller_id: ['Seller/Id',Tag_by_str],
    category_id: ['CategoryId',Tag_by_int],
    category_path: ['CategoryPath',Tag_by_str],
    seller_point: ['Seller/Rating/Point',Tag_by_int],
    seller_suspended: ['Seller/Rating/IsSuspended',Tag_by_bool],
    seller_deleted: ['Seller/Rating/IsDeleted',Tag_by_bool],
    auction_item_url: ['AuctionItemUrl',Tag_by_str],
    images: ['',Proc.new {|elem|
	  imgs = []
	  %w(Image1 Image2 Image3).each do |tag|
		  imgs << Tag_by_str.call(elem,tag)
	  end
	  next imgs 
      }],
    init_price: ['Initprice',Tag_by_int],
    current_price: ['Price',Tag_by_int],
    quantity: ['Quantity',Tag_by_int],
    bids: ['Bids',Tag_by_int],
    description: ['Description',Tag_by_str],
    item_condition: ['ItemStatus/Condition',Tag_by_str],
    item_condition_comment: ['ItemStatus/Comment',Tag_by_str],
    item_returnable: ['ItemReturnable/Allowed',Tag_by_bool],
    start_time: ['StartTime',Tag_by_datetime],
    end_time: ['EndTime',Tag_by_datetime],
    buy_price: ['BidOrBuy',Tag_by_int],

    is_reserved: ['Reserved',Tag_by_int],
    bidder_restriction: ['IsBidderRestrictions',Tag_by_bool],
    early_closing: ['IsEarlyClosing',Tag_by_bool],
    down_offer: ['IsOffer',Tag_by_bool],
    store: ['StoreIcon',Tag_has_url],  
    checked: ['CheckIcon',Tag_has_url],  
    featured: ['FeaturedIcon',Tag_has_url],  
    free_shipping: ['FreeshippingIcon',Tag_has_url],  
    easypayment: ['EasyPaymentIcon',Tag_has_url],
    charge_for_shopping: ['ChargeForShopping',Tag_by_str],
    ship_location: ['Location',Tag_by_str],
    ship_time: ['ShipTime',Tag_by_str],
    size: ['Size',Tag_by_int],
    weight: ['Weight',Tag_by_int],
    charity_percent: ['CharityOption/Proportion',Tag_by_int],
  }

  attr_accessor :auction_id,:attrs,:info_when_get

  def initialize
     @attrs = {}
     # attrs には原則元xmlのタグをsnake_caseにしたものを使う
     @info_when_get= {} 
  end

  def valid?
    [:title,:seller_id,:auction_item_url].each do |sym|
      return false if @attrs[sym] == "" || !@attrs[sym].is_a?(String)
    end
    
    return false if !@attrs[:end_time].is_a?(DateTime)

    [:current_price,:bids].each do |sym|
      return false if !@attrs[sym].is_a?(Integer)
    end

    return true
  end
  def get_tags(elem,tags)
    # 1つのitemに相当する部分のxmlを渡す
    tags.each do |key,val|
      tag_name = val[0]
      proc_ = val[1]
      raise unless tag_name && proc_
      content = proc_.call(elem,tag_name)
      self.attrs[key]  = content if content != nil
    end
    @auction_id = Tag_by_str.call(elem,'AuctionID')
    self
  end


  def update!
    request_url = "http://auctions.yahooapis.jp/AuctionWebService/V2/auctionItem?appid=#{@@api_key}&auctionID=#{self.auction_id}"
    xmlstr = open(request_url)
    doc = Nokogiri.XML(xmlstr)
    self.get_tags(doc,Item_tags)
    
    self.info_when_get[:from_self] = {}
    self.info_when_get[:from_self][:get_date] = DateTime.now  
  end


end
