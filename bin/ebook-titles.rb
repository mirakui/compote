Book.where(is_adult:false, is_ebook:true).
  joins(:publisher).order(:title).pluck(:title).each do |title|
  puts title
end
