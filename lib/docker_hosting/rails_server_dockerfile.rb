require 'docker_hosting/helpers/docker_helpers'

module DockerHosting
  class RailsServerDockerfile
    include DockerHosting::Helpers::DockerHelpers

    attr_accessor :config

    def initialize(config = DockerHosting)
      @config = config
    end

    def build!
      [
          'FROM centos',
          build_base,
          build_ruby,
          build_project,
          build_nodejs,
          build_cmd,
          ''
      ].join("\n")
    end

    def image_tag
      [config.app_name, config.app_env, 'app'].map(&:underscore).join('_')
    end

    def project_root
      '/srv/app' unless config.app_volumes.key?(config.app_root)

      config.app_volumes[config.app_root]
    end

    private
    def build_cmd
      cmd = [
          cmd_bundle('install --path .bundle --binstubs'),
          "rm -rf #{File.join(project_root, 'tmp/pids/server.pid')}",
          cmd_bundle('exec rails s -b 0.0.0.0')
      ]

      'CMD ' + rvm_shell(cmd_wrap(cmd))
    end

    def build_nodejs
      [
          cmd_run('curl --silent --location https://rpm.nodesource.com/setup | bash -'),
          cmd_system_package('nodejs')
      ]
    end

    def build_project
      cmd_run("mkdir -p #{project_root}")
    end

    def build_base
      config.packages.map { |package| cmd_system_package(package) }
    end

    def build_ruby
      [
          cmd_run('curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -'),
          cmd_run('curl -sSL https://get.rvm.io | bash -s stable'),
          cmd_run('source /etc/profile.d/rvm.sh'),
          cmd_env_path('/usr/local/rvm/bin/'),
          cmd_rvm_shell('rvm requirements'),
          cmd_rvm_shell("rvm install #{config.ruby_version}"),
          cmd_rvm_shell("rvm use --default #{config.ruby_version}"),
          cmd_rvm_shell('rvm rubygems latest'),
          cmd_rvm_shell('gem install bundler')
      ]
    end

    def cmd_bundle(cmd)
      cmd_wrap(["cd #{project_root}", "bundle #{cmd}"])
    end

    def rvm_shell(cmd)
      "/bin/bash -l -c '#{cmd}'"
    end

    def cmd_rvm_shell(cmd)
      cmd_run(rvm_shell(cmd))
    end
  end
end
