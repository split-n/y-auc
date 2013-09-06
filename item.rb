# encoding:utf-8
require 'date'
require './yahoo_api.rb'
require 'nokogiri'

class Item
  include YahooAPI
  Tag_by_str = Proc.new { |elem,target_tag|
        elem_part = elem.at(target_tag)
        elem_part ? elem_part.inner_text : nil
    }
    
    Tag_by_int = Proc.new { |elem,target_tag|
      tag_str = Tag_by_str.call(elem,target_tag)
      tag_str ? tag_str.to_i : nil
    }

    Tag_has_url = Proc.new { |elem,target_tag|
      tag_str = Tag_by_str.call(elem,target_tag)
      tag_str ? (tag_str =~ /http/) : false
    }

    Tag_by_datetime = Proc.new {|elem,target_tag|
      tag_str = Tag_by_str.call(elem,target_tag)
      tag_str ? DateTime.parse(tag_str) : nil
    }

    Tag_by_bool = Proc.new { |elem,target_tag|
      tag_str = Tag_by_str.call(elem,target_tag)
      tag_str ? (tag_str=="true") : nil
    }


  TAGS_TABLE = {
      # refer: http://developer.yahoo.co.jp/webapi/auctions/
      # 格納symbol: xpath,取得proc
      auction_id: ['AuctionID',Tag_by_str],
      title: ['Title',Tag_by_str],
      seller_id: ['Seller/Id',Tag_by_str],
      auction_item_url: ['AuctionItemUrl',Tag_by_str],
      image: ['Image',Tag_by_str],
      current_price: ['CurrentPrice',Tag_by_int],
      bids: ['Bids',Tag_by_int],
      end_time: ['EndTime',Tag_by_datetime],
      bid_or_buy: ['BidOrBuy',Tag_by_int],
      is_reserved: ['IsReserved',Tag_by_bool ],
      charity_percent: ['CharityOption/Proportion',Tag_by_int],
      affiliate_rate: ['Affiliate/Rate',Tag_by_int],

      new_sale: ['NewIcon',Tag_has_url],
      store: ['StoreIcon',Tag_has_url],  
      checked: ['CheckIcon',Tag_has_url],  
      public: ['PublicIcon',Tag_has_url],  
      featured: ['FeaturedIcon',Tag_has_url],  
      free_shipping: ['FreeshippingIcon',Tag_has_url],  
      new_item: ['NewItemIcon',Tag_has_url],
      wrapping: ['WrappingIcon',Tag_has_url],
      easypayment: ['EasyPaymentIcon',Tag_has_url],
      is_offer: ['IsOffer',Tag_by_bool],
      is_adult: ['IsAdult',Tag_by_bool],

      category_id: ['CategoryId',Tag_by_int],



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
  def get_tags(elem)
    # 1つのitemに相当する部分のxmlを渡す
    TAGS_TABLE.each do |key,val|
      tag_name = val[0]
      proc_ = val[1]
      raise unless tag_name && proc_
      content = proc_.call(elem,tag_name)
      self.attrs[key]  = content if content != nil
    end
    self
  end


  def update

  end

  private
  def get_my_info
    
  end

end
