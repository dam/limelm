require 'spec_helper'
SUPPORT_ROOT = File.expand_path("../support", File.dirname(__FILE__))

describe LimeLm do
  before do 
    @conf = { api_key: '123', version_id: '100' }
  end

  describe '.config' do 
    it 'returns a default configuration to a LimeLM demo environment' do 
      config = LimeLm.config
      assert !config.empty?
      assert_equal LimeLm.class_variable_get(:@@valid_config_keys), config.keys
    end
  end

  describe '.configure' do 
    it 'configures the module passing a hash' do
      LimeLm.configure(@conf) 
      assert_equal @conf, LimeLm.config 
    end

    it 'rejects unexpected keys' do 
      LimeLm.configure(@conf.merge({ unexpected: '234' })) 
      assert_equal @conf, LimeLm.config
    end
  end

  describe '.configure_with' do 
    it 'configures the module through a yaml file' do 
      LimeLm.configure_with("#{SUPPORT_ROOT}/conf.yml")
      config = LimeLm.config
      assert_equal 'new_key_from_yaml', config[:api_key]
      assert_equal '1', config[:version_id]
    end
  end
end