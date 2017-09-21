# little script to format sebco data into import data
require './config/environment'

puts "Deleting all from import file table"
ImpFrmt.delete_all

# go through website book table and insert data first from there


Book.all.each do |b|
  #puts "Creating an import record for #{b.title} : #{b.ISBN13}"
  ebook_isbn = (b.eb_ISBN13.nil? || b.eb_ISBN13 == 'NULL' ) ?   '' : b.eb_ISBN13
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

#updating import file series names
Serie.all.each do |s|
  #puts "Updating book series names for #{s.ID} - #{s.title} "
  series_books =  ImpFrmt.find_all_by_series_code(s.ID)
  series_books.each do |sb|
    sb.update_attribute(:series, s.title)
  end
end

# Go through export from esebco and fill ou the info or create
# record if needed
MlExp.all.each do |mlb|
  imp_rec = ImpFrmt.find_by_isbn(mlb.number)
  dewey_number = (mlb.dewey_number.to_s.strip == '0.0' || mlb.dewey_number.to_s.strip == '0') ? '' : mlb.dewey_number
  if imp_rec
    copy_year = (imp_rec.copyright_date.empty? || imp_rec.copyright_date == 'NULL' ) ? mlb.copyright_year : imp_rec.copyright_date
    imp_rec.update_attributes(
      copyright_date: copy_year,
      dewey: dewey_number,
      author: mlb.author,
      int_level: mlb.int_lvls,
      read_level: mlb.rd_lvls,
      length: mlb.page_count,
      binding: mlb.media_type,
      lex: mlb.lexile_measure,
      bisac_cats: mlb.subjects,
      atos_l: mlb.atos_level ,
      atos_int_lvl: mlb.ar_int ,
      atos_p: mlb.ar_points ,
      quiz: mlb.ar_quiz,
      rc_lvl: mlb.rc_level ,
      rc_pnts: mlb.rc_points,
      grl: mlb.grl


    )
  else
    puts "Esebco has #{mlb.title} - #{mlb.number} and mlane doesn't"
    if !mlb.title.empty?
      ImpFrmt.create(
          {
              title: mlb.title,
              isbn: mlb.number,
              book_code: '',
              series: '' ,
              series_code: '',
              price: '',
              lib_price: '',
              copyright_date: mlb.copyright_year,
              pub_marketing: mlb.description,
              dewey: dewey_number,
              author: mlb.author,
              int_level: mlb.int_lvls,
              read_level: mlb.rd_lvls,
              length: mlb.page_count,
              binding: mlb.media_type,
              lex: mlb.lexile_measure,
              bisac_cats: mlb.subjects,
              atos_l: mlb.atos_level ,
              atos_int_lvl: mlb.ar_int ,
              atos_p: mlb.ar_points ,
              quiz: mlb.ar_quiz,
              rc_lvl: mlb.rc_level ,
              rc_pnts: mlb.rc_points,
              grl: mlb.grl

          }
      )
    end
  end

  #final pass through scraped data to fill in the blanks
  check_data = %w{ title price copyright_date pub_marketing dewey author int_level read_level length binding lex bisac_cats atos_l
                   atos_int_lvl atos_p quiz rc_lvl rc_pnts grl}
  ImpFrmt.all.each do |imp|
    in_rec = InScrape.find_by_isbn(imp.isbn)
    bow_rec = BScrape.find_by_isbn(imp.isbn)
    check_data.each do |cd|
      check_val = imp.send(cd).to_s
      if check_val.blank?
        i_val = in_rec.send(imp)
        if !i_val.blank?
          imp.update_attribute(cd.to_sym,i_val)
        else
          b_val = bow_rec.send(imp)
          if !b_val.empty?
            imp.update_attribute(cd.to_sym,b_val)
          end
        end
      end
    end

  end






end