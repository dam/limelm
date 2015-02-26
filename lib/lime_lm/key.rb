module LimeLm
  class Key
  	attr_reader :id
  	attr_reader :key
  	attr_reader :version_id
  	attr_reader :email
    attr_reader :properties  	

  	def initialize(hash)
      self.send(:assign_properties, hash)
      raise LimeLm::InvalidObject, 'You need to provide at least an id or a key for the LimeLm::Key object' unless @id || @key
    end

    class << self
      def find(email, params={})
      	version_id = params.delete(:version_id) { LimeLm.config[:version_id] }

      	response = LimeLm::Connection.post_json({ method: 'limelm.pkey.find', version_id: version_id, email: email })
        response['pkeys']['pkey'].map { |k| new(k.merge!({ 'version_id' => version_id, 'email' => email })) } 
      end
    end  

    def details
      response = LimeLm::Connection.post_json({ method: 'limelm.pkey.getDetails', pkey_id: @id })
      self.send(:assign_properties, response['pkey'])
    end

    private

    def assign_properties(hash)
      @id         = hash['id']
      @key        = hash['key']
      @version_id = hash['version_id']
      @email      = hash['email']
      @properties = hash
    end
  end
end