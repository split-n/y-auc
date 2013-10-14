# encoding:utf-8

module YaXML

   Tag_by_str = Proc.new { |elem,target_tag|
        elem_part = elem.at(target_tag)
        elem_part ? elem_part.inner_text.strip : nil
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

    
  def self.get_tags(elem,tags)
    # 1つのitemに相当する部分のxmlを渡す
    attributes = {}
    tags.each do |key,val|
      tag_name = val[0]
      proc_ = val[1]
      raise unless tag_name && proc_
      content = proc_.call(elem,tag_name)
      attributes[key]  = content if content != nil
    end
    auction_id = Tag_by_str.call(elem,'AuctionID')
    return [auction_id,attributes]
  end


end






