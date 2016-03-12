require 'test_helper'
require 'generators/docker_hosting/hosting_generator'

class HostingGeneratorTest < Rails::Generators::TestCase
  tests ::DockerHosting::Generators::HostingGenerator
  destination File.expand_path('../../tmp', __FILE__)
  setup { prepare_destination }

  test 'generate hosting configurations for sqlite3' do
    ActiveRecord::Base.configurations[Rails.env] = {
        'adapter' => 'sqlite3'
    }

    run_generator %w(hosting_generator)
    assert_file 'config/hosting/Dockerfile'
  end

  test 'generate hosting configurations for postgresql' do
    ActiveRecord::Base.configurations[Rails.env] = {
        'adapter' => 'postgresql'
    }

    run_generator %w(hosting_generator)
    assert_file 'config/hosting/Dockerfile'
  end
end
