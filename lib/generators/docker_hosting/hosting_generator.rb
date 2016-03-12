require 'docker'

module DockerHosting
  module Generators
    class HostingGenerator < Rails::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)

      desc 'Generate hosting'

      def create_hosting
        template 'hosting.rb', 'config/initializers/hosting.rb'

        # noinspection RubyResolve
        require Rails.root.join('config/initializers/hosting.rb')

        remove_file 'config/hosting/Dockerfile'
        create_file 'config/hosting/Dockerfile', build_dockerfile

        build_image

        build_container
      end

      private
      def project_root
        '/srv/app'
      end

      def image_tag
        [Rails.env, Rails.application.class.parent.name].map(&:underscore).join('_')
      end

      def build_container
        begin
          puts Docker::Container.get(image_tag).delete(force: true)
        rescue Docker::Error::NotFoundError
          # ignored
        end

        volumes = Hash[*DockerHosting.app_volumes.values.map { |v| {v => {}} }.collect { |v| v.to_a }.flatten]

        container = Docker::Container.create(
            'name'          => image_tag,
            'Image'         => image_tag,
            'Volumes':      volumes,
            'ExposedPorts': {
                '3000/tcp': {}
            },
            'HostConfig':   {
                'Binds':        DockerHosting.app_volumes.map { |k, v| "#{k}:#{v}" },
                'PortBindings': {
                    '3000/tcp': [{'HostPort': '5000'}]
                },
            },
        )
        container.start!
      end

      def build_nodejs
        out = []
        out << cmd_run('curl -sL https://rpm.nodesource.com/setup_5.x | bash -')
        out << cmd_system_package('nodejs')
        out
      end

      def build_image
        Docker.url                    = DockerHosting.docker_url
        Docker.options[:read_timeout] = DockerHosting.docker_read_timeout

        dockerfile = File.read(File.expand_path('config/hosting/Dockerfile', destination_root))
        image      = Docker::Image.build(dockerfile)
        image.tag(repo: image_tag)
        image
      end

      def build_project
        out = []
        out << cmd_run("mkdir -p #{project_root}")
        out
      end

      def build_dockerfile
        out = ['FROM centos']
        out << build_base
        out << build_ruby
        out << build_database
        out << build_project
        out << build_cmd
        out << build_nodejs
        out << ''
        out.join("\n")
      end

      def build_cmd
        cmd = [
            cmd_bundle('install --path .bundle --binstubs'),
            "rm -rf #{File.join(project_root, '/tmp/pids/server.pid')}",
            cmd_bundle('exec rails s -b 0.0.0.0')
        ]

        'CMD ' + rvm_shell(cmd_wrap(cmd))
      end

      def build_base
        DockerHosting.packages.map { |package| cmd_system_package(package) }
      end

      def build_ruby
        out = []
        out << cmd_run('curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -')
        out << cmd_run('curl -sSL https://get.rvm.io | bash -s stable')
        out << cmd_run('source /etc/profile.d/rvm.sh')
        out << cmd_env_path('/usr/local/rvm/bin/')
        out << cmd_rvm_shell('rvm requirements')
        out << cmd_rvm_shell("rvm install #{DockerHosting.ruby_version}")
        out << cmd_rvm_shell("rvm use --default #{DockerHosting.ruby_version}")
        out << cmd_rvm_shell('rvm rubygems latest')
        out << cmd_rvm_shell('gem install bundler')
        out
      end

      def build_database
        out             = []
        database_config = ActiveRecord::Base.configurations[Rails.env]
        adapter         = database_config['adapter']
        case adapter
          when 'sqlite3'
            out << cmd_run('yum install -y sqlite')
          when 'postgresql'
            package_file = File.basename(DockerHosting.postgresql_package)

            out << cmd_run(['cd /opt',
                            "wget #{DockerHosting.postgresql_package}",
                            "rpm -Uvh #{package_file}",
                            "rm -rf #{package_file}"])
            out << cmd_env_path(DockerHosting.postgresql_bin)
            out << cmd_run("#{DockerHosting.postgresql_ctrl} start")
          else
            raise "Unknown database adapter #{adapter}"
        end
      end

      def cmd_run(cmd)
        "RUN #{cmd_wrap(cmd)}"
      end

      def cmd_rvm_shell(cmd)
        cmd_run(rvm_shell(cmd))
      end

      def rvm_shell(cmd)
        "/bin/bash -l -c '#{cmd}'"
      end

      def cmd_wrap(cmd)
        Array.wrap(cmd).join(" \\ \n    && ")
      end

      def cmd_env_path(path)
        "ENV PATH #{Array.wrap(path).join(':')}:$PATH"
      end

      def cmd_system_package(package)
        cmd_run("yum install -y #{package}")
      end

      def cmd_bundle(cmd)
        cmd_wrap(["cd #{project_root}", "bundle #{cmd}"])
      end
    end
  end
end
