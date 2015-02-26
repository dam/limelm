SPEC_ROOT = File.dirname(__FILE__)
GEM_ROOT = File.expand_path("..", SPEC_ROOT)

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
Dir["#{SPEC_ROOT}/support/**/*.rb"].each { |f| require f }

# VCR configuration
VCR.configure do |c|
  c.cassette_library_dir = "#{SPEC_ROOT}/fixtures/dish_cassettes"
  c.hook_into :webmock
end


# TODO: only if passing live mode
module MinitestPlugin
  def before_setup
    # NOTE: As LimeLM doesn't provide a demo environment, we have to make the following tricks:
    #       1) Add personal credentials configuration to the file conf.yml, verify that this file is not version controlled
    #       2) Run your tests with the environment variable MODE sets to 'live': bundle exec rake spec MODE=live
    #       3) The HTTP request succeed and are regitered by VCR as fixtures
    #       4) Anonymize each new created VCR fixtures with the credentials available under spec/support/config.yml 
    #          + don't forget to anonymize each creadentials presents in the API response
    #       5) Add the option match_requests_on: [:path] to the VCR#use_cassette method to lock the fixture on next live MODE
    #       6) Run the testing without the MODE environment variable, the fixtures should works

    if ENV['MODE'] == 'live' && File.exist?("#{GEM_ROOT}/conf.yml")
      LimeLm.configure_with("#{GEM_ROOT}/conf.yml") 
    else 
      LimeLm.configure_with("#{SPEC_ROOT}/support/conf.yml")
    end
  end
end

class MiniTest::Test
  include MinitestPlugin
end
