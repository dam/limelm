require 'spec_helper'

describe LimeLm::Key do 
  describe '.find' do 
    it 'returns a list of keys associated with an email' do 
      email = 'imberdis.damien@gmail.com'
      VCR.use_cassette("find_keys_by_email") do
        keys = LimeLm::Key.find(email)
        assert_equal 2, keys.count
        key = keys.first
        assert !key['id'].empty?, 'A key should contains the id information'
        assert !key['key'].empty?, 'A key should contains the key information'
        assert !key['acts'].empty?, 'A key should contains the total of activations information'
        assert !key['acts_used'].empty?, 'A key should contains the used activations information'
      end
    end
  end
end