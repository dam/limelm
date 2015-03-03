require 'spec_helper'

describe LimeLm::Feature do
  describe '#initialize' do 
    it 'sets default object attributes' do 
      feature = LimeLm::Feature.new({
      	'id'          => '1', 
      	'name'        => 'updates_expires', 
      	'type'        => 'date_time',
        'ta_readable' => 'true', 
        'required'    => 'false', 
        'description' => "Date when the license key expires."
      })
      assert_equal '1', feature.id
      assert_equal 'updates_expires', feature.name
      assert_equal 'date_time', feature.type
      assert feature.ta_readable
      assert !feature.required
      assert !feature.description.empty?
    end
  end

  describe '.all' do 
    it 'returns all the custom license fields for a given product version' do 
      VCR.use_cassette("all_features", match_requests_on: [:path]) do
        result = LimeLm::Feature.all(version_id: '2')
        assert_equal 1, result.count
        feature = result.first
        assert_instance_of LimeLm::Feature, feature
      end
    end
  end 

  describe '.create' do 
    it 'creates a new product custom license field with a name by default' do
      VCR.use_cassette("create_product_default_feature", match_requests_on: [:path]) do
        new_feature_name = 'plan'
        result = LimeLm::Feature.create(name: new_feature_name)
        assert_instance_of LimeLm::Feature, result
        assert_equal '2', result.id
        assert_equal 'string', result.type
        assert result.required, 'required by default'
        assert result.ta_readable, 'readable by default'
      end  
    end

    it 'accepts more specified options' do 
      VCR.use_cassette("create_custom_feature", match_requests_on: [:path]) do
        result = LimeLm::Feature.create(name: 'customized_plan', type: 'int', required: 'false',
          ta_readable: 'false', description: 'new customized field')
        assert_equal '3', result.id
        assert_equal 'customized_plan', result.name
        assert_equal 'int', result.type
        assert_equal 'new customized field', result.description
        assert !result.required
        assert !result.ta_readable
      end
    end
  end 
end