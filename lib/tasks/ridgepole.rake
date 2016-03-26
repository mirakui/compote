def ridgepole_cmd(*opts)
  opts = %W[
    -a
    -c config/database.yml
    --enable-mysql-awesome
    -E #{Rails.env}
  ].concat opts
  "bundle exec ridgepole #{opts.flatten.join(' ')}"
end

namespace :ridgepole do
  desc 'apply ridgepole'
  task apply: :environment do
    sh ridgepole_cmd
  end

  desc 'dry-run ridgepole'
  task 'dry-run' => :environment do
    sh ridgepole_cmd('--dry-run')
  end
end
