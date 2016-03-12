require 'test_helper'
require 'docker_hosting/rails_server_dockerfile'

class RailsServerDockerfileTest < ::ActiveSupport::TestCase
  test 'generate Dockerfile' do
    # noinspection RubyResolve
    require '../lib/generators/templates/hosting'

    dockerfile = DockerHosting::RailsServerDockerfile.new(DockerHosting).build!

    assert_equal("FROM centos
RUN yum install -y curl
RUN yum install -y which
RUN yum install -y vim
RUN yum install -y wget
RUN yum install -y lsof
RUN yum install -y git
RUN curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN source /etc/profile.d/rvm.sh
ENV PATH /usr/local/rvm/bin/:$PATH
RUN /bin/bash -l -c 'rvm requirements'
RUN /bin/bash -l -c 'rvm install 2.2.1'
RUN /bin/bash -l -c 'rvm use --default 2.2.1'
RUN /bin/bash -l -c 'rvm rubygems latest'
RUN /bin/bash -l -c 'gem install bundler'
RUN mkdir -p /srv/app
RUN curl -sL https://rpm.nodesource.com/setup_5.x | bash -
RUN yum install -y nodejs
CMD /bin/bash -l -c 'cd /srv/app \\ 
    && bundle install --path .bundle --binstubs \\ 
    && rm -rf /srv/app/tmp/pids/server.pid \\ 
    && cd /srv/app \\ 
    && bundle exec rails s -b 0.0.0.0'
", dockerfile)
  end
end
