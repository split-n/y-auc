# encoding:utf-8
require_relative './yahoo_api.rb'
require_relative './list_items.rb'
require_relative './xml_parse_sets.rb'

include XmlParseSets
class AuctionListItems < ListItems
  include YahooAPI


  # 格納symbol: xpath,取得proc
  Common_tags = {
      title: ['Title',Tag_by_str],
      seller_id: ['Seller/Id',Tag_by_str],
      auction_item_url: ['AuctionItemUrl',Tag_by_str],
      image: ['Image',Tag_by_str],
      current_price: ['CurrentPrice',Tag_by_int],
      bids: ['Bids',Tag_by_int],
      end_time: ['EndTime',Tag_by_datetime],
      buy_price: ['BidOrBuy',Tag_by_int],
      is_reserved: ['IsReserved',Tag_by_bool ],
      charity_percent: ['CharityOption/Proportion',Tag_by_int],
      affiliate_rate: ['Affiliate/Rate',Tag_by_int],

      new_sale: ['NewIcon',Tag_has_url],
      store: ['StoreIcon',Tag_has_url],  
      checked: ['CheckIcon',Tag_has_url],  
      public: ['PublicIcon',Tag_has_url],  
      featured: ['FeaturedIcon',Tag_has_url],  
      free_shipping: ['FreeshippingIcon',Tag_has_url],  
      item_condition: ['NewItemIcon',proc{|elem,tag|
	  Tag_has_url.call(elem,tag) ? new : "not_new"
      } ],
      wrapping: ['WrappingIcon',Tag_has_url],
      easypayment: ['EasyPaymentIcon',Tag_has_url],
      is_offer: ['IsOffer',Tag_by_bool],
      is_adult: ['IsAdult',Tag_by_bool],
  }

  def initialize(opt={})
    raise unless @@api_key
    super()
    @options = opt
  end


  def get_items_xml(url)
    items_xml_list = []
    xmlfile = open(url)
    doc = Nokogiri::XML(xmlfile)
    doc.search('Item').each do |elem|
      items_xml_list << elem
    end
    items_xml_list
  end




end


