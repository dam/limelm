require 'spec_helper'

describe LimeLm::Key do
  describe '#initialize' do 
    it 'raises an error if no id and no product key specified during Object creation' do 
      assert_raises(LimeLm::InvalidObject) { LimeLm::Key.new({}) }
      LimeLm::Key.new({ 'id' => '1' })
      LimeLm::Key.new({ 'key' => 'AAAA-BBBB' })
    end
  end
  

  describe '#details' do 
    it 'assigns properties of a key and returns them' do 
      VCR.use_cassette("details_for_a_given_key", match_requests_on: [:path]) do
        key = LimeLm::Key.new({ 'id' => '1' })
        result = key.details
        assert !key.key.empty?, 'Details about a key should reassign the key property'
        assert !key.email.empty?, 'Details about a key should reassign the email property'
        assert result.is_a?(Hash), 'All the properties should be returned'
      end
    end

    it 'including all custom license fields and tags' do
      #TODO 
    end
  end
 
  describe '.find' do 
    it 'returns a list of keys associated with an email' do 
      email = 'imberdis.damien@gmail.com'
      VCR.use_cassette("find_keys_by_email", match_requests_on: [:path]) do
        keys = LimeLm::Key.find(email)
        assert_equal 2, keys.count
        key = keys.first
        assert key.is_a?(LimeLm::Key)

        assert key.properties.is_a?(Hash) && !key.properties.empty?, 'All data are stored as a Hash under properties'
        assert !key.id.empty?, 'A key should contains the id information'
        assert !key.key.empty?, 'A key should contains the key information'
        assert !key.version_id.empty?, 'A key as a link to its product version'
        assert !key.email.empty?, 'A key as a link to the user email provided'
        assert !key.properties['acts'].empty?, 'A key should contains the total of activations information'
        assert !key.properties['acts_used'].empty?, 'A key should contains the used activations information'
      end
    end
  end
end