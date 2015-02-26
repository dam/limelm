TEST_ROOT = File.dirname(__FILE__)

require 'simplecov'

module SimpleCov::Configuration
  def clean_filters
    @filters = []
  end
end

SimpleCov.configure do
  clean_filters
  load_profile 'test_frameworks'
end

ENV["COVERAGE"] && SimpleCov.start do
  add_filter "/.rvm/"
  add_filter "/.rbenv/"
  add_filter "/.bundle/"
end
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'minitest/autorun'
require 'shoulda'
require 'webmock/minitest'
require 'vcr'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'limelm'

# Support methods
Dir["#{TEST_ROOT}/support/**/*.rb"].each { |f| require f }

# VCR configuration
VCR.configure do |c|
  c.cassette_library_dir = "#{TEST_ROOT}/fixtures/dish_cassettes"
  c.hook_into :webmock
end
