require 'compote/crawler'
require 'dotenv/tasks'

namespace :crawler do
  desc 'start crawler'
  task start: :environment do
    crawler = Compote::Crawler.new
    crawler.start
  end

end
