def dump_clusters_to_md(clusters, dev)
  clusters.each do |key, books|
    dev.puts "## #{key}"
    books.sort_by do |b|
      b[2].try(:to_s, :db) || b[3].try(:to_s, :db) || ''
    end.each do |book|
      publisher_name, authors, published_on, released_on, title, asin = book
      dev.puts "- [#{title}](http://www.amazon.co.jp/dp/#{asin})"
    end
    dev.puts
  end
end

book_clusters = Hash.new {|h,k| h[k] = [] }

Book.where(is_adult:false, is_ebook:true).
  joins(:publisher).
  pluck('publishers.name as publisher_name', :authors, :published_on, :released_on, :title, :asin).
each do |b|
  publisher_name, authors, published_on, released_on, title, asin = b
  authors = authors.gsub("\t", ',')
  cluster_key = [publisher_name, authors].join(': ')
  book_clusters[cluster_key] << b
end

dump_clusters_to_md book_clusters, $stdout
