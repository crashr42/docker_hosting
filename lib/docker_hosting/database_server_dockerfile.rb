require 'docker_hosting/helpers/docker_helpers'

module DockerHosting
  class DatabaseServerDockerfile
    include DockerHosting::Helpers::DockerHelpers

    attr_accessor :config

    def initialize(config = {})
      @config = config
    end

    def build!
      [
          'FROM centos',
          build_database,
          build_cmd,
          ''
      ].join("\n")
    end

    def image_tag
      [config.app_name, config.app_env, 'db'].map(&:underscore).join('_')
    end

    private
    def build_database
      case config.app_database['adapter']
        when 'postgresql'
          package_file = File.basename(config.postgresql_package)

          [
              cmd_run(['cd /opt',
                       "wget #{config.postgresql_package}",
                       "rpm -Uvh #{package_file}",
                       "rm -rf #{package_file}"]),
              cmd_env_path(config.postgresql_bin),
              cmd_run("#{config.postgresql_ctrl} start")
          ]
        else
          raise "Unknown database adapter #{config.app_database['adapter']}"
      end
    end
  end
end
