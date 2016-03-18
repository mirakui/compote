require 'compote/crawler'
require 'compote/importer'
require 'dotenv/tasks'

namespace :compote do
  namespace :crawler do
    desc 'start crawler'
    task start: :environment do
      crawler = Compote::Crawler.new
      crawler.start
    end
  end

  namespace :books do
    desc 'import books from crawled items'
    task import: :environment do
      importer = Compote::Importer.new
      importer.start
    end
  end
end
