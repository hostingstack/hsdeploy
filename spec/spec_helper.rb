ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require "rubygems"
require "bundler/setup"

require 'rspec'
require 'deploytool'
require 'logger'

RSpec.configure do |config|
  config.mock_with :rr
end

$logger = Logger.new File.expand_path('../spec.log', __FILE__)
$logger.formatter = proc { |severity, datetime, progname, msg|
  "#{severity} #{datetime.strftime("%Y-%m-%d %H:%M:%S")}: #{msg}\n"
}