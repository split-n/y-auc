# encoding:utf-8
require_relative '../core/item.rb'
require_relative '../core/yahoo_api.rb'
require_relative '../core/xml_parse_sets.rb'

include XmlParseSets

describe Item do
  
  before :all do 

  xmlfile = File.open('./testdata/search_per_item_data.xml')
  xml_str = xmlfile.read
  xmlfile.close

  @xml = Nokogiri.parse(xml_str)

   YahooAPI.set_api_key( 
     File.read('../key.txt',encoding: Encoding::UTF_8).chomp )

  end

  it "searchの部分的なxmlからget_tagsが問題なくparseできているか" do
    item = Item.new
    require_relative '../core/auction_list_items.rb'
    require_relative '../core/search_items.rb'
    item.get_tags(@xml,AuctionListItems::Common_tags.merge(SearchItems::Search_tags))
    item.auction_id.should  == "t305862326"
    item.title.should == "Lenovo ThinkPad L512 4444-RR1■i5-2.4/2G/250/7Pro(DtoD)#10"
    item.seller_id.should == "used_pc_shop2000"
    item.category_id.should == 2084307191
    item.auction_item_url.should == "http://page15.auctions.yahoo.co.jp/jp/auction/t305862326"
    item.images.length.should == 1
    item.current_price.should == 35000
    item.end_time.should  == (DateTime.parse "2013-09-05T21:43:52+09:00")
    item.reserved?.should be_false
    item.charity_percent.should == 0
    item.affiliate_rate.should == 1
    item.free_shipping?.should be_false
    item.new_sale?.should be_true
    item.store?.should be_true
    item.checked?.should be_false
    item.public?.should be_false
    item.featured?.should be_false
    item.free_shipping?.should be_false
    item.item_condition.should == "not_new"
    item.wrapping?.should be_false
    item.easypayment?.should be_false
    item.has_offer?.should be_false
    item.adult?.should be_false

     
  end

  it "内容のアップデートが出来る" do 
    item = Item.new
    item.get_tags(@xml,Item::Item_tags)
    item.update!
    expect(
    item.description.is_a?(String) &&
    item.description.length > 10  ).to be_true
    expect(
    item.item_condition =="used" ).to be_true
  end
  

    









end
