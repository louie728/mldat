class ScrapeRecord < ActiveRecord::Base
  self.abstract_class = true

  def read_level_map
    # map of esebco values to reading values
    {1=>"1st Grade", 2=>"2nd Grade", 3=>"3rd Grade", 4=>"4th Grade",
     5=>"5th Grade", 6=>"6th Grade", 7=>"7th Grade",
     8=>"8th Grade", 0=>"Kindergarten", 10=>"Young Adult", 11=>"Adult", 9=>"Pre-Kindergarten"}
  end

  def int_level_map
    {1=>"Primary", 2=>"Middle", 3=>"Secondary",
     4=>"Adult", 5=>"All", 0=>"Kindergarten", 11=>"Intermediate"}
  end

  def mlane_int_level
    rtn = ''
    if !(self.int_level.nil? || self.int_level.blank?)
      hash_map = int_level_map
      property_array = self.int_level.split(',').map{|i| i.to_i}
      ta = []
      property_array.each do |av|
        ta << hash_map[av]
      end
      rtn = ta.join(',')
    end
    rtn
  end

  def mlane_read_level
    rtn = ''
    if !(self.read_level.nil? || self.read_level.blank?)
      hash_map = read_level_map
      property_array = self.read_level.split(',').map{|i| i.to_i}
      ta = []
      property_array.each do |av|
        ta << hash_map[av]
      end
      rtn = ta.join(',')
    end
    rtn
  end

  def mlane_bisac_cats
    s = self.read_attribute(:bisac_cats)
    if (s && s[0] == '-')
      s = s[1..-1].strip
    end
    s
  end

end