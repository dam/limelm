require 'spec_helper'

describe LimeLm::Key do
  describe '#initialize' do 
    it 'raises an error if no id and no product key specified during Object creation' do 
      assert_raises(LimeLm::InvalidObject) { LimeLm::Key.new({}) }
      LimeLm::Key.new({ 'id' => '1' })
      LimeLm::Key.new({ 'key' => 'AAAA-BBBB' })
    end

    it 'sets default object attributes' do 
      key = LimeLm::Key.new({ 'id' => '1', 'key' => 'AAA-BBB', 'version_id' => '1',
        'email' => 'imberdis.damien@gmail.com' })
      assert_equal 'imberdis.damien@gmail.com', key.email
      assert_equal 'AAA-BBB', key.key
      assert_equal '1', key.version_id
      assert !key.revoked, 'A key is not revoked by default'
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
      VCR.use_cassette("details_for_a_given_key_with_tags", match_requests_on: [:path]) do
        key = LimeLm::Key.new({ 'id' => '1' })
        result = key.details
        assert_equal [{"name"=>"enterprise"}, {"name"=>"demo"}], result['tags']['tag']
      end
    end
  end
  
  describe '#id' do 
    it 'returns the id property if already present in the object' do 
      key = LimeLm::Key.new({ 'id' => '1' })
      assert_equal '1', key.id
    end

    it 'calls the API, save the id property and returns it if only the product key is present' do 
      VCR.use_cassette("id_for_a_given_key", match_requests_on: [:path]) do
        key = LimeLm::Key.new({ 'key' => 'AAAA-BBBB' })
        assert_equal '1', key.id
      end
    end
  end

  describe '#tag' do
    it 'sets a key tags providing an Array' do
      VCR.use_cassette("set_tags_for_a_given_key", match_requests_on: [:path]) do
        key = LimeLm::Key.new({ 'id' => '1' }) 
        tags = ['demo', 'enterprise']
        assert key.tag(tags), 'returns true if success'
      end
    end
  end

  describe '#remove_tag' do 
    it 'removes the specialized tag' do 
      VCR.use_cassette("remove_tag_for_a_given_key", match_requests_on: [:path]) do
        key = LimeLm::Key.new({ 'id' => '1' }) 
        assert key.remove_tag('demo'), 'returns true if success'
      end
    end
  end

  describe '#update' do 
    #TODO: https://wyday.com/limelm/help/api/limelm.pkey.setDetails/
  end 

  describe '#toggle_revoke!' do 
    it 'calls the API and set revoked to true in case of success for a non revoked key' do 
      VCR.use_cassette("revoke_key", match_requests_on: [:path]) do
        key = LimeLm::Key.new({ 'id' => '1' }) 
        assert !key.revoked, 'By default a key is not revoked after its initialization'
        key.toggle_revoke!
        assert key.revoked, 'The key is revoked if succeed'
      end
    end

    it 'calls the API and unrevoke the key' do 
      VCR.use_cassette("unrevoke_key", match_requests_on: [:path]) do
        key = LimeLm::Key.new({ 'id' => '1', 'revoked' => true }) 
        assert key.revoked, 'the key should be revoked'
        key.toggle_revoke!
        assert !key.revoked, 'Unrevoke the key'
      end
    end
  end

  describe '.create' do 
    it 'creates a new default product key' do 
      VCR.use_cassette("create_key_default_configuration", match_requests_on: [:path]) do
        result = LimeLm::Key.create
        assert_equal 1, result.count, 'Should build an uniq key by default'
        new_key = result.first
        assert_instance_of LimeLm::Key, new_key
        assert_equal '9', new_key.id
        assert_equal 'CCCC-BBBB', new_key.key
        assert new_key.version_id, 'version_id is set to the default configuration'
      end
    end

    it 'associates keys to an email and can generate more than a key' do 
      VCR.use_cassette("create_keys_with_email", match_requests_on: [:path]) do
        email = 'imberdis.damien@gmail.com'

        result = LimeLm::Key.create(email: email, num_keys: 2)
        assert_equal 2, result.count

        first_key, second_key = result.first, result.last
        assert_instance_of LimeLm::Key, first_key
        assert_instance_of LimeLm::Key, second_key

        assert_equal email, first_key.email
        assert_equal email, second_key.email
      end
    end

    it 'accept more detailed configuration about the limitation of activations/deactivations' do 
      VCR.use_cassette("create_detailed_key", match_requests_on: [:path]) do 
        email = 'imberdis.damien@gmail.com'

        result = LimeLm::Key.create(email: email, num_acts: 5, deact_limit: 2)
        assert '9', result.first.id
        assert 'CCCC-EEEE', result.first.key
      end
    end

    it 'accepts the creation of a new key, specifying a product version_id (not using the default configuration)' do 
      VCR.use_cassette("create_key_new_version", match_requests_on: [:path]) do
        result = LimeLm::Key.create(version_id: '2')
        assert_equal '2', result.first.version_id
      end
    end
  end

  describe '#destroy!' do 
    it 'deletes a key' do 
      VCR.use_cassette("destroy_key", match_requests_on: [:path]) do
        key_to_destroy = LimeLm::Key.new({ 'id' => '1' })
        assert key_to_destroy.destroy!, 'Should return true if key deleted'
      end
    end

    it 'raises error if try to delete a key out of my version_id' do 
      VCR.use_cassette("destroy_random_key", match_requests_on: [:path]) do
        key_to_destroy = LimeLm::Key.new({ 'id' => '3' })
        assert_raises(LimeLm::ApiError) { key_to_destroy.destroy! }   
      end
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

  describe '.search' do 
    it 'returns by default 20 keys of all products and versions' do 
      VCR.use_cassette("default_search", match_requests_on: [:path]) do
        result = LimeLm::Key.search
        
        # NOTE: the next values are only set for the purpose of a test
        assert_equal 2, result.count
        first_key, last_key = result.first, result.last

        assert_instance_of LimeLm::Key, first_key
        assert_equal '1', first_key.id
        assert_equal '1', first_key.version_id

        assert_instance_of LimeLm::Key, last_key
        assert_equal '2', last_key.id
        assert_equal '4', last_key.version_id
      end 
    end

    it 'paginates the result returned' do 
      VCR.use_cassette("default_search_pagination", match_requests_on: [:path]) do
        result = LimeLm::Key.search(num: 2, page: 3)   
        assert_equal 2, result.count

        first_key = result.first
        assert_instance_of LimeLm::Key, first_key
        assert_equal '10', first_key.id
        assert_equal '2', first_key.version_id
      end
    end
  end

  describe '.activity' do
    it 'returns the activity of a product version for the last week by default' do 
      VCR.use_cassette("default_activity", match_requests_on: [:path]) do
        result = LimeLm::Key.activity(version_id: '1')
        assert result.is_a?(Array)
        key_info = result.first
        assert_equal '1', key_info["id"] 
        assert_equal "AAAA", key_info['key']
        assert_equal "5", key_info['acts']
      end 
    end

    it 'returns an empty array if no activity results found' do 
      VCR.use_cassette("no_activity", match_requests_on: [:path]) do
        result = LimeLm::Key.activity
        assert_equal [], result
      end
    end
  end
end