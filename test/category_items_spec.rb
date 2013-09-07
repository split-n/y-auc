# encoding:utf-8

require_relative '../core/category_items.rb'

describe CategoryItems do 
  before :all do 
    
    YahooAPI.set_api_key( 
      File.read('../key.txt',encoding: Encoding::UTF_8).chomp )

      TP13_ID = 2084307189
  end

    it "価格順クエリを発行したものがきちんとソートされている" do
      cate = CategoryItems.new(TP13_ID,{sort_by: :current_price,order: :asc})
      past = 0
      cate.take(80).each do |item|
         curr = item.attrs[:current_price] 
         (past <= curr).should be_true
         past = curr
      end
    end

    
    it "条件付クエリを発行した結果が全て条件を満たしている" do
      cate = CategoryItems.new(TP13_ID,{buynow: true,item_status: :used,store: :normal})
      cate.take(100).each do |item|
        item.attrs[:store].should be_false
        item.attrs[:bid_or_buy].should be_a_kind_of Integer
        item.attrs[:new_item].should be_false

      end
    end

    it "真逆の条件クエリでテスト" do
      cate = CategoryItems.new(TP13_ID,{buynow: false,item_status: :new,store: :store})
      cate.take(100).each do |item|
        item.attrs[:store].should be_true
        item.attrs[:bid_or_buy].should be_nil
        item.attrs[:new_item].should be_true

      end
    end

  end


