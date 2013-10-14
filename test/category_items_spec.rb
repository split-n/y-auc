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
         curr = item.current_price 
         expect(past).to be <= curr
         past = curr
      end
    end

    
    it "条件付クエリを発行した結果が全て条件を満たしている" do
      cate = CategoryItems.new(TP13_ID,{buynow: true,item_status: :used,store: :normal})
      cate.take(100).each do |item|
        item.store?.should be_false
        item.buy_price.should be_a_kind_of Integer
        item.item_condition.should eq "not_new"

      end
    end

    it "真逆の条件クエリでテスト" do
      cate = CategoryItems.new(TP13_ID,{buynow: false,item_status: :new,store: :store})
      cate.take(100).each do |item|
        item.store?.should be_true
       item.buy_price.should be_nil
        item.item_condition.should eq "new"

      end
    end

    it "即決価格の範囲指定が正常にされているか確認" do 
      max = 50000
      min = 30000
      cate = CategoryItems.new(TP13_ID,{min_buy_price: min,max_buy_price: max})
      cate.take(50).each do |item|
        item.buy_price.should be_within(max).of(min)
      end
    end



  end


