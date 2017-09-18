class ImpFrmt < ActiveRecord::Base

  attr_accessible   :title, :isbn, :book_code, :series, :series_code , :price, :lib_price , :copyright_date , :pub_marketing, :flip_isbn

end