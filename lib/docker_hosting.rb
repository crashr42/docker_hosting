module DockerHosting
  mattr_accessor :docker_url
  mattr_accessor :docker_read_timeout
  mattr_accessor :packages
  mattr_accessor :postgresql_package
  mattr_accessor :postgresql_ctrl
  mattr_accessor :postgresql_bin
  mattr_accessor :ruby_version
  mattr_accessor :app_port

  def self.setup
    yield self
  end
end
