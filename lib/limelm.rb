require 'httparty'
require 'yaml'

Dir[File.dirname(__FILE__) + '/lime_lm/*.rb'].each { |file| require file } 

module LimeLm
  # Configuration defaults, TO set if a demo environment is available on the future
  @@config = { api_key: '', version_id: '' }
  @@valid_config_keys = @@config.keys

  class << self
    def configure(opts = {})
      opts.each {|k,v| @@config[k.to_sym] = v if @@valid_config_keys.include? k.to_sym}
    end

    def configure_with(path_to_yaml_file)
      config = YAML::load(IO.read(path_to_yaml_file))
    rescue Errno::ENOENT
      log(:warning, "YAML configuration file couldn't be found. Using defaults."); return
    rescue Psych::SyntaxError
      log(:warning, "YAML configuration file contains invalid syntax. Using defaults."); return
    else
      configure(config)	
    end

    def config
      @@config
    end
  end
end