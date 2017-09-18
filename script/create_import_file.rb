# little script to format sebco data into import data
require './config/environment'

puts "Deleting all from import file table"
ImpFrmt.delete_all

# go through website book table and insert data first from there


Book.all.each do |b|
  puts "Creating and import record for #{b.title} : #{b.ISBN13}"
  ebook_isbn = (b.eb_ISBN13.nil?) ?   '' : b.eb_ISBN13
  ImpFrmt.create(
   {
    title: b.title,
    isbn: b.ISBN13,
    book_code: '',
    series: '' ,
    series_code: b.ID,
    price: b.list_price,
    lib_price: b.SL_price,
    copyright_date: b.copywrite,
    pub_marketing: b.description,
    flip_isbn: ebook_isbn
   }
  )
end