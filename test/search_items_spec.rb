# encoding:utf-8

require_relative '../core/search_items.rb'

describe SearchItems do 
  before :all do 
    YahooAPI.set_api_key( 
      File.read('../key.txt',encoding: Encoding::UTF_8).chomp )
  end

  it "検索クエリに指定した文字列が一般商品のタイトルに含まれている" do 
    query = "ThinkPad"
    search = SearchItems.new(query,{store: :normal})
    matcher = Regexp.new(query, Regexp::IGNORECASE)
    search.take(90).each do |item|
      item.attrs[:title].should match matcher

    end
  end

  it "複数同時にソート順を保ち動くことの確認" do
    search1 = SearchItems.new("Ruby",{sort_by: :end_time,order: :asc})
    search2 = SearchItems.new("Java",{sort_by: :end_time,order: :asc})
    
    en1 = search1.take(80).to_enum
    en2 = search2.take(80).to_enum

    tmp1 = tmp2 = DateTime.new

   loop do
       next1 = en1.next
       (next1.attrs[:end_time] > tmp1).should be_true
       tmp1 = next1.attrs[:end_time] 
       next2 = en2.next
       (next2.attrs[:end_time] > tmp2).should be_true
       tmp2 = next2.attrs[:end_time] 
    end

     
  end





end

