module LimeLm
  class Key
    attr_reader :id
    attr_reader :key
    attr_reader :version_id
    attr_reader :email
    attr_reader :revoked
    attr_reader :properties  	

    def initialize(hash)
      self.send(:assign_properties, hash)
      raise LimeLm::InvalidObject, 'You need to provide at least an id or a key for the LimeLm::Key object' unless @id || @key
    end

    class << self
      def create(params={})
        version_id = params.delete(:version_id) { LimeLm.config[:version_id] }

        response = LimeLm::Connection.post_json({ method: 'limelm.pkey.generate', version_id: version_id }.merge!(params))
        additional_info = { 'version_id' => version_id }
        additional_info['email'] = params[:email]  if params[:email]
        response['pkeys']['pkey'].map { |k| new(k.merge!(additional_info)) }
      end

      def find(email, params={})
      	version_id = params.delete(:version_id) { LimeLm.config[:version_id] }

      	response = LimeLm::Connection.post_json({ method: 'limelm.pkey.find', version_id: version_id, email: email })
        response['pkeys']['pkey'].map { |k| new(k.merge!({ 'version_id' => version_id, 'email' => email })) } 
      end
    end

    def id(params={})
      return @id if @id
      
      version_id = params.delete(:version_id) { LimeLm.config[:version_id] }
      response = LimeLm::Connection.post_json({ method: 'limelm.pkey.getID', version_id: version_id, pkey: @key })
      @id = response['pkey']['id']
    end

    def tag(tags=[])
      response = LimeLm::Connection.post_json({ method: 'limelm.pkey.setTags', pkey_id: @id, tag: tags })
      true
    end 
    
    def remove_tag(tag)
      response = LimeLm::Connection.post_json({ method: 'limelm.pkey.removeTag', pkey_id: @id, tag: tag })
      true
    end

    def details
      response = LimeLm::Connection.post_json({ method: 'limelm.pkey.getDetails', pkey_id: @id })
      self.send(:assign_properties, response['pkey'])
    end

    def destroy!
      response = LimeLm::Connection.post_json({ method: 'limelm.pkey.delete', pkey_id: @id })
      true
    end

    def toggle_revoke!
      revoke = @revoked ? 'false' : 'true'
      response = LimeLm::Connection.post_json({ method: 'limelm.pkey.revoke', pkey_id: @id, revoke: revoke })
      @revoked = !@revoked
    end

    private

    def assign_properties(hash)
      @id         = hash['id']
      @key        = hash['key']
      @version_id = hash['version_id']
      @email      = hash['email']
      @revoked    = hash['revoked'] || false
      @properties = hash
    end
  end
end