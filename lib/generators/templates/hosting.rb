DockerHosting.setup do |config|
  config.docker_url          = 'tcp://0.0.0.0:2376'
  config.docker_read_timeout = 5.minutes
  config.packages            = %w(curl which vim wget lsof git)
  config.postgresql_package  = 'http://oscg-downloads.s3.amazonaws.com/packages/postgresql-9.5.1-1-x64-bigsql.rpm'
  config.postgresql_ctrl     = '/etc/init.d/postgresql-95'
  config.postgresql_bin      = '/opt/postgresql/pg95/bin'
  config.ruby_version        = '2.2.1'
end
