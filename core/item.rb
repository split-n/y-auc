# encoding:utf-8
require 'date'
require 'nokogiri'
require 'open-uri'
require_relative './yahoo_api.rb'
require_relative './ya_xml.rb'


include YaXML

class Item
  include YahooAPI
  @@available_tags = []


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

    :'reserved?' => ['Reserved',Tag_by_int],
    :'has_bidder_restriction?' => ['IsBidderRestrictions',Tag_by_bool],
    :'early_closing?' => ['IsEarlyClosing',Tag_by_bool],
    :'can_down_offer?' => ['IsOffer',Tag_by_bool],
    :'store?' =>  ['StoreIcon',Tag_has_url],  
    :'checked?' => ['CheckIcon',Tag_has_url],  
    :'featured?' => ['FeaturedIcon',Tag_has_url],  
    :'free_shipping?' => ['FreeshippingIcon',Tag_has_url],  
    :'easypayment?' => ['EasyPaymentIcon',Tag_has_url],
    charge_for_shopping: ['ChargeForShopping',Tag_by_str],
    ship_location: ['Location',Tag_by_str],
    ship_time: ['ShipTime',Tag_by_str],
    ship_size: ['Size',Tag_by_int],
    ship_weight: ['Weight',Tag_by_int],
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

  def attrs=(arg) 
    orig = arg
    selected = arg.select do |key,val|
      @@available_tags.include? key
    end
    if orig.length != arg.length
      diff = orig.reject do |key,val|
        selected[key]
      end
      raise diff.inspect 
    end
    @attrs = selected 
  end
  



  def update!
    request_url = "http://auctions.yahooapis.jp/AuctionWebService/V2/auctionItem?appid=#{@@api_key}&auctionID=#{self.auction_id}"
    xmlstr = open(request_url)
    doc = Nokogiri.XML(xmlstr)
    result = YaXML.get_tags(doc,Item_tags)
    self.attrs= result[1]
     
    self.info_when_get[:from_self] = {}
    self.info_when_get[:from_self][:get_date] = DateTime.now  
  end

  def self.create_tags_reader(*arg)
    arg.each do |symb|
      define_method(symb) do
        attrs[symb]
      end
      @@available_tags << symb
    end
  end

  # @attribute [r]
  # @return [String] アイテムのタイトル
  create_tags_reader :title

  # @attribute [r]
  # @return [String] アイテムの出品者のID
  create_tags_reader :seller_id
  
  # @attribute [r]
  # @return [Integer] カテゴリID
  create_tags_reader :category_id
  
  # @attribute [r]
  # @return [String] カテゴリへのパス
  create_tags_reader :category_path
  
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
  # @return [Integer] アフィリエイト料率 ない場合はnil
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

  # 以上までがcat,searchから持ってきた物

  # @attribute [r]
  # @return [String] 紹介文本文
  create_tags_reader :description
  
  # @attribute [r]
  # @return [String] アイテムの状態
  create_tags_reader :item_condition

  # @attribute [r]
  # @return [String] アイテムの状態説明文
  create_tags_reader :item_condition_comment

  # @attribute [r]
  # @return [Boolean] 返品可能
  create_tags_reader :item_returnable

  # @attribute [r]
  # @return [DateTime] 開始日時 
  create_tags_reader :start_time

  # @attribute [r]
  # @return [Boolean] 入札者制限の有無
  create_tags_reader :'has_bidder_restriction?'

  # @attribute [r]
  # @return [Boolean] 早期終了の有無
  create_tags_reader :'early_closing?'

  # @attribute [r]
  # @return [Boolean] 値下げ交渉の有無
  create_tags_reader :'can_down_offer?'

  # @attribute [r]
  # @return [String] 送料負担者
  create_tags_reader :charge_for_shopping

  # @attribute [r]
  # @return [String] 発送地
  create_tags_reader :ship_location

  # @attribute [r]
  # @return [Boolean] 代金先払い/後払い
  create_tags_reader :ship_time

  # @attribute [r]
  # @return [Integer] 発送時の3辺合計サイズ
  create_tags_reader :ship_size

  # @attribute [r]
  # @return [Boolean] 発送重量
  create_tags_reader :ship_weight
end
