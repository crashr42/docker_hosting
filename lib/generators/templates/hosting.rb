DockerHosting.setup do |config|
  config.docker_url          = 'tcp://0.0.0.0:2376'
  config.docker_read_timeout = 5.minutes
  config.packages            = %w(curl which vim wget lsof git sqlite)
  config.postgresql_package  = 'http://oscg-downloads.s3.amazonaws.com/packages/postgresql-9.5.1-1-x64-bigsql.rpm'
  config.postgresql_ctrl     = '/etc/init.d/postgresql-95'
  config.postgresql_bin      = '/opt/postgresql/pg95/bin'
  config.ruby_version        = '2.2.1'
  config.app_env             = Rails.env
  config.app_name            = Rails.application.class.parent.name
  config.app_root            = Rails.root
  config.app_database        = ActiveRecord::Base.configurations[config.app_env]
  config.app_volumes         = {
      config.app_root => '/srv/app'
  }
  config.app_ports           = {
      '5000/tcp': '3000/tcp'
  }
end
