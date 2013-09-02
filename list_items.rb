# encoding:utf-8
require './yahoo_api.rb'

class ListItems 
  include Enumerable
  include YahooAPI

  attr_reader  :items, :options

  

  def initialize(opt)
    raise unless @@api_key
    @items = {}
    @options = opt
    @read_page = 0
    @tags_table = {
      auction_id: ['AuctionID',String],
      seller_id: ['Seller/Id',String],
      auction_item_url: ['AuctionItemUrl',String],
      image: ['Image',String],
      end_time: ['EndTime',DateTime],
      current_price: ['CurrentPrice',Integer],
      bid_or_buy: ['BidOrBuy',Integer],
      bids: ['Bids',Integer],
      category_id: ['CategoryId',Integer]
    }
  end

  def each
    # すでにあるitemsをyieldした後に新たに順次取得しyield
    @items.each do |key,val|
      yield val
    end
    while (items = get_next_page) != {}
      items.each do |key,val|
        yield val unless @items[key]
        @items[key] = val
      end
    end
  end
  
  
  def get_all
    @read_page = 0
    while (next_list = get_next_page) != {}
        @items.merge! next_list 
    end
  end

  private
  def get_next_page
    url = create_request_url(@read_page+1) 
    item_list = get_item_list(url)
    @read_page += 1
    puts  "read:#{@read_page} page" if $DEBUG
    return item_list
  end


  def create_request_url(page)
    raise NotImplementedError
  end

  def get_item_list(url)
    raise NotImplementedError
  end

  def get_tags(item,elem,require_tags)
    # 1つのitemに相当する部分のxmlを渡す
    binding.pry
    require_tags.each do |key|
      node_name = @tags_table[key][0]
      type = @tags_table[key][1]
      raise unless node_name
      

      innertext = elem.at(node_name).inner_text
      case type
      when String
        item.attrs[key] = innertext
      when DateTime
        item.attrs[key] = DateTime.parse(innertext) 
      when Integer
        item.attrs[key] = innertext.to_i
      end
    end
    return item
  end
end
