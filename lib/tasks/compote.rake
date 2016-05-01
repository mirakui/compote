require 'compote/crawler'
require 'compote/importer'
require 'compote/exporter'
require 'compote/pipeline/daily_update'
require 'dotenv/tasks'

namespace :compote do
  namespace :crawler do
    desc 'start crawler'
    task :start, [:month_ago] => :environment do |task, args|
      pipe = Compote::Pipeline::DailyUpdate.new
      pipe.start month_ago: args[:month_ago].to_i
    end
  end

  namespace :books do
    desc 'export book titles as TSV'
    task export: :environment do
      raise 'please specify output filename as ENV["FILE"]' unless ENV['FILE']
      exporter = Compote::Exporter.new ENV['FILE']
      exporter.start
    end
  end
end
