$:.unshift File.expand_path("../lib", __FILE__)
require "hsdeploy/version"

Gem::Specification.new do |gem|
  gem.name    = "hsdeploy"
  gem.version = HSDeploy::VERSION

  gem.author      = "HostingStack"
  gem.email       = "maintainers@hostingstack.org"
  gem.homepage    = "http://hostingstack.org/"
  gem.summary     = "PaaS deployment tool."
  gem.description = "Deployment tool for web application platforms powered by HostingStack."
  gem.executables = "hsdeploy"

  gem.files = %x{ git ls-files }.split("\n").select { |d| d =~ %r{^(README|bin/|data/|ext/|lib/|spec/|test/)} }
  
  gem.add_dependency "inifile",        ">= 0.4.1"
  gem.add_dependency "addressable"
  gem.add_dependency "multipart-post"
  gem.add_dependency "highline",       ">= 1.6.2"
  gem.add_dependency "zip"
  gem.add_dependency "json_pure"
  gem.add_dependency "oauth2"
end
