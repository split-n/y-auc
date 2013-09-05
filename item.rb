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
      tag_str ? (tag_str =~ /http/) : nil
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
      # 格納symbol: xpath,取得proc
      auction_id: ['AuctionID',Tag_by_str],
      seller_id: ['Seller/Id',Tag_by_str],
      auction_item_url: ['AuctionItemUrl',Tag_by_str],
      image: ['Image',Tag_by_str],
      end_time: ['EndTime',Tag_by_datetime],
      current_price: ['CurrentPrice',Tag_by_int],
      bid_or_buy: ['BidOrBuy',Tag_by_int],
      bids: ['Bids',Tag_by_int],
      category_id: ['CategoryId',Tag_by_int],
      title: ['Title',Tag_by_str],
      is_reserved: ['IsReserved',Tag_by_bool ],
      store: ['StoreIcon',"Boolean"], #to do 
      new_item: ['NewItemIcon',"Boolean"],
      description: ['Description',Tag_by_str],
      easypayment_creditcard: ['EasyPayment/IsCreditCard',"Boolean"],
      easypayment_netbank: ['EasyPayment/IsNetBank',"Boolean"],
      charge_for_shipping: ['ChargeForShipping',"String"], # to do
      location: ['Location',Tag_by_str],
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
  def get_tags(elem,require_tags)
    # 1つのitemに相当する部分のxmlを渡す
    require_tags.each do |key|
      tag_name = TAGS_TABLE[key][0]
      proc_ = TAGS_TABLE[key][1]
      raise unless tag_name && proc_
      self.attrs[tag_name] = proc_.call(elem,tag_name)
    end
    self
  end


  def update

  end

  private
  def get_my_info
    
  end

end
