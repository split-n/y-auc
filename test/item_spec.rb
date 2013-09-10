# encoding:utf-8
require_relative '../core/item.rb'
require_relative '../core/yahoo_api.rb'

describe Item do
  
  before :all do 
    xml_str = <<'ENDOFSTRING'
<Item>
<AuctionID>t305862326</AuctionID>
<Title>
Lenovo ThinkPad L512 4444-RR1■i5-2.4/2G/250/7Pro(DtoD)#10
</Title>
<CategoryId>2084307191</CategoryId>
<Seller>
<Id>used_pc_shop2000</Id>
<ItemListUrl>
http://auctions.yahooapis.jp/AuctionWebService/V2/sellingList?sellerID=used_pc_shop2000
</ItemListUrl>
<RatingUrl>
http://auctions.yahooapis.jp/AuctionWebService/V1/ShowRating?id=used_pc_shop2000
</RatingUrl>
</Seller>
<ItemUrl>
http://auctions.yahooapis.jp/AuctionWebService/V2/auctionItem?auctionID=t305862326
</ItemUrl>
<AuctionItemUrl>
http://page15.auctions.yahoo.co.jp/jp/auction/t305862326
</AuctionItemUrl>
<Image width="125" height="100">
http://auctions.c.yimg.jp/f13batchimg.auctions.yahoo.co.jp/users/7/5/4/2/used_pc_shop2000-thumb-1367478875880085.jpg
</Image>
<CurrentPrice>35000.00</CurrentPrice>
<Bids>0</Bids>
<EndTime>2013-09-05T21:43:52+09:00</EndTime>
<IsReserved>false</IsReserved>
<CharityOption>
<Proportion>0</Proportion>
</CharityOption>
<Affiliate>
<Rate>1</Rate>
</Affiliate>
<Option>
<NewIcon>
http://image.auctions.yahoo.co.jp/i/auctions/new3.gif
</NewIcon>
<StoreIcon>
http://image.auctions.yahoo.co.jp/images/premium.gif
</StoreIcon>
<IsBold>false</IsBold>
<IsBackGroundColor>false</IsBackGroundColor>
<IsOffer>false</IsOffer>
<IsCharity>false</IsCharity>
</Option>
<IsAdult>false</IsAdult>
</Item>
ENDOFSTRING
  @xml = Nokogiri.parse(xml_str)

   YahooAPI.set_api_key( 
     File.read('../key.txt',encoding: Encoding::UTF_8).chomp )

  end

  it "categoryLeafの部分的なxmlからget_tagsが問題なくparseできているか" do
    item = Item.new
    item.get_tags(@xml,Common_tags)
    item.auction_id.should  == "t305862326"
    item.attrs[:free_shipping].should == false
    item.attrs[:current_price].should == 35000
     
  end

  it "内容のアップデートが出来る" do 
    item = Item.new
    item.get_tags(@xml,Common_tags)
    item.update!
    expect(
    item.attrs[:description].is_a?(String) &&
    item.attrs[:description].length > 10  ).to be_true
  end
  

    









end
