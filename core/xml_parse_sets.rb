# encoding:utf-8

module XmlParseSets

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
      if (tag_str =~ /http/)
        true
      else
        false
      end
    }

    Tag_by_datetime = Proc.new {|elem,target_tag|
      tag_str = Tag_by_str.call(elem,target_tag)
      tag_str ? DateTime.parse(tag_str) : nil
    }

    Tag_by_bool = Proc.new { |elem,target_tag|
      tag_str = Tag_by_str.call(elem,target_tag)
      tag_str ? (tag_str=="true") : nil
    }


      # 格納symbol: xpath,取得proc
  Common_tags = {
      title: ['Title',Tag_by_str],
      seller_id: ['Seller/Id',Tag_by_str],
      auction_item_url: ['AuctionItemUrl',Tag_by_str],
      image: ['Image',Tag_by_str],
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
      new_item: ['NewItemIcon',Tag_has_url],
      wrapping: ['WrappingIcon',Tag_has_url],
      easypayment: ['EasyPaymentIcon',Tag_has_url],
      is_offer: ['IsOffer',Tag_by_bool],
      is_adult: ['IsAdult',Tag_by_bool],
  }

























end






