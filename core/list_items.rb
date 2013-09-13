# encoding:utf-8
require_relative './yahoo_api.rb'

class ListItems 
  include Enumerable

  attr_reader  :items, :options

  

  def initialize()
    items = {}
    @read_page = 0
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

end
