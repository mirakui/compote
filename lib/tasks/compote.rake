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
end
