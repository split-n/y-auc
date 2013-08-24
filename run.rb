# encoding:utf-8
require './auc.rb'

CategoryItems.set_api_key('')

cat = CategoryItems.new(2084193586)
cat.get_first_page
pp cat.items