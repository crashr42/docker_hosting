$:.push File.expand_path('../lib', __FILE__)
$:.push File.expand_path('../test', __FILE__)

# Maintain your gem's version:
require 'docker_hosting/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'docker_hosting'
  s.version     = DockerHosting::VERSION
  s.authors     = ['Nikita Koshkin']
  s.email       = ['nikita.kem@gmail.com']
  s.homepage    = 'TODO'
  s.summary     = 'TODO: Summary of DockerHosting.'
  s.description = 'TODO: Description of DockerHosting.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '~> 4.2.5.2'
  s.add_dependency 'docker-api'

  s.add_development_dependency 'sqlite3'
end
