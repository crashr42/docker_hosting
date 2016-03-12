require 'docker'
require 'docker_hosting/rails_server_dockerfile'

module DockerHosting
  module Generators
    class HostingGenerator < Rails::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)

      desc 'Generate hosting'

      def create_hosting
        template 'hosting.rb', 'config/initializers/hosting.rb'

        # noinspection RubyResolve
        require Rails.root.join('config/initializers/hosting.rb')

        dockerfile = DockerHosting::RailsServerDockerfile.new

        remove_file 'config/hosting/Dockerfile'
        create_file 'config/hosting/Dockerfile', dockerfile.build!

        build_image(dockerfile)

        build_container(dockerfile)
      end

      private
      def build_container(dockerfile)
        begin
          puts Docker::Container.get(dockerfile.image_tag).delete(force: true)
        rescue Docker::Error::NotFoundError
          # ignored
        end

        volumes       = Hash[*dockerfile.config.app_volumes.values.map { |v| {v => {}} }.collect { |v| v.to_a }.flatten]
        exposed_ports = Hash[*dockerfile.config.app_ports.map { |_k, v| {v => {}} }.collect { |v| v.to_a }.flatten]
        port_bindings = Hash[*dockerfile.config.app_ports.map { |k, v| {v => [{'HostPort': k.to_s.split('/').first}]} }.collect { |v| v.to_a }]

        container = Docker::Container.create(
            'name'          => dockerfile.image_tag,
            'Image'         => dockerfile.image_tag,
            'Volumes':      volumes,
            'ExposedPorts': exposed_ports,
            'WorkingDir':   dockerfile.project_root,
            'HostConfig':   {
                'Binds':        dockerfile.config.app_volumes.map { |k, v| "#{k}:#{v}" },
                'PortBindings': port_bindings,
            },
        )
        container.start!
      end

      def build_image(dockerfile)
        Docker.url                    = dockerfile.config.docker_url
        Docker.options[:read_timeout] = dockerfile.config.docker_read_timeout

        image = Docker::Image.build(File.read(File.expand_path('config/hosting/Dockerfile', destination_root)))
        image.tag(repo: dockerfile.image_tag)
        image
      end
    end
  end
end
