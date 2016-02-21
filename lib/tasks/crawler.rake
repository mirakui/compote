require 'compote/crawler'

namespace :crawler do
  desc 'start crawler'
  task start: :environment do
    crawler = Compote::Crawler.new
    crawler.crawl_comic_list
  end

end
