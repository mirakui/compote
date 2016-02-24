namespace :ridgepole do
  desc 'apply ridgepole'
  task apply: :environment do
    sh "bundle exec ridgepole -a -c config/database.yml -E #{Rails.env}"
  end

  desc 'dry-run ridgepole'
  task 'dry-run' => :environment do
    sh "bundle exec ridgepole -a -c config/database.yml -E #{Rails.env} --dry-run"
  end

end
