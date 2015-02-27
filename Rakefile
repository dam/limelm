# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "limelm"
  gem.homepage = "http://github.com/dam/limelm"
  gem.license = "MIT"
  gem.summary = %Q{limelm is a Ruby wrapper for the LimeLM JSON API}
  gem.description = %Q{limelm is a Ruby wrapper for the LimeLM JSON API}
  gem.email = "imberdis.damien@gmail.com"
  gem.authors = ["Damien Imberdis"]
  # dependencies defined in Gemfile
  gem.add_runtime_dependency 'httparty'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'vcr'
  gem.add_development_dependency 'rdoc', '~> 3.12'
  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'jeweler', '~> 2.0.1'
  gem.add_development_dependency 'simplecov', '>= 0'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['spec'].execute
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "limelm #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
