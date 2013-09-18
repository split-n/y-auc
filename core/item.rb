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




  attr_accessor :auction_id,:info_when_get
  attr_reader :attrs

  def initialize
     @attrs = {}
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

  def self.create_tags_reader(*arg)
    arg.each do |symb|
      define_method(symb) do
        attrs[symb]
      end
    end
  end

  # @attribute [r]
  # @return [String] アイテムのタイトル
  create_tags_reader :title

  # @attribute [r]
  # @return [String] アイテムの出品者のID
  create_tags_reader :seller_id
  
  # @attribute [r]
  # @return [String] アイテムのブラウザからのアクセス用URL
  create_tags_reader :auction_item_url
  
  # @attribute [r]
  # @return [Array] 画像のurlの配列が帰る
  # すべての画像が入っているかは取得方法による
  create_tags_reader :images

  # @attribute [r]
  # @return [Integer] 現在の金額
  create_tags_reader :current_price

  # @attribute [r]
  # @return [Integer] 入札数
  create_tags_reader :bids
  
  # @attribute [r]
  # @return [DateTime] 終了時刻
  create_tags_reader :end_time

  # @attribute [r]
  # @return [Integer] 即決価格
  create_tags_reader :buy_price
  # @attribute [r]
  # @return [Boolean] 最低価格の有無
  create_tags_reader :'reserved?'
  # @attribute [r]
  # @return [Integer] チャリティオプション寄付率
  # ない場合は0
  create_tags_reader :charity_percent
  # @attribute [r]
  # @return [アフィリエイト料率]
  # ない場合はnil
  create_tags_reader :affiliate_rate
  # @attribute [r]
  # @return [Boolean] 新登場の商品
  create_tags_reader :'new_sale?'
  # @attribute [r]
  # @return [Boolean] ストア出品商品
  create_tags_reader :'store?'
  # @attribute [r]
  # @return [Boolean] 鑑定済み商品
  create_tags_reader :'checked?'
  # @attribute [r]
  # @return [Boolean] 官公庁オークション
  create_tags_reader :'public?'
  # @attribute [r]
  # @return [Boolean] 注目のオークション
  create_tags_reader :'featured?'
  # @attribute [r]
  # @return [Boolean] 送料無料
  create_tags_reader :'free_shipping?'
  # @attribute [r]
  # @return [String] 商品の状態、新品の場合は"new"
  # @todo 見直す
  create_tags_reader :item_condition
  # @attribute [r]
  # @return [Boolean] 贈答品
  create_tags_reader :'wrapping?'
  # @attribute [r]
  # @return [Boolean] かんたん決済対応
  create_tags_reader :'easypayment?'
  # @attribute [r]
  # @return [Boolean] 値下げ交渉可能
  create_tags_reader :'has_offer?'
  # @attribute [r]
  # @return [Boolean] アダルトカテゴリ商品
  create_tags_reader :'adult?'
  # @attribute [r]
  # @return [Integer] カテゴリID
  create_tags_reader :category_id
  
  create_tags_reader :category_path
    # 以上までがcat,searchから持ってきた物

end
