require 'date'

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
        additional_info = LimeLm::Utils.stringify_keys(params.merge!({ version_id: version_id }))
        response['pkeys']['pkey'].map { |k| new(k.merge!(additional_info)) }
      end

      def find(email, params={})
      	version_id = params.delete(:version_id) { LimeLm.config[:version_id] }

      	response = LimeLm::Connection.post_json({ method: 'limelm.pkey.find', version_id: version_id, email: email })
        response['pkeys']['pkey'].map { |k| new(k.merge!({ 'version_id' => version_id, 'email' => email })) } 
      end

      def search(params={})
        response = LimeLm::Connection.post_json({ method: 'limelm.pkey.advancedSearch'}.merge!(params))
        response['pkeys']['pkey'].map { |k| new(k) }
      end

      # Returns by default activity of created product keys only to speed up the query
      # Pass optional activity as parameters. Asking for activity of all the products takes a long process time
      def activity(params={})
        version_id = params.delete(:version_id) { LimeLm.config[:version_id] }
        start = params.delete(:start) { (Date.today - 7).strftime('%Y-%m-%d') }

        response = LimeLm::Connection.post_json({ method: 'limelm.pkey.activity', version_id: version_id, start: start, created: true}.merge!(params))
        response['pkeys']['pkey']
      rescue LimeLm::ApiError => e
        e.message.include?('109') ? [] : raise(e)
      end

      def manual_activation(act_req_content)
        response = LimeLm::Connection.post_json({ method: 'limelm.pkey.manualActivation', act_req_xml: act_req_content})
        response['act_resp_xml']['data']    
      end

      def manual_deactivation(deact_req_content)
        response = LimeLm::Connection.post_json({ method: 'limelm.pkey.manualDeactivation', deact_req_xml: deact_req_content})
      end
    end

    def id(params={})
      return @id if @id
      
      version_id = params.delete(:version_id) { LimeLm.config[:version_id] }
      response = LimeLm::Connection.post_json({ method: 'limelm.pkey.getID', version_id: version_id, pkey: @key })
      @id = response['pkey']['id']
    end

    def tag(tags=[])
      LimeLm::Connection.post_json({ method: 'limelm.pkey.setTags', pkey_id: @id, tag: tags })
      true
    end 
    
    def remove_tag(tag)
      LimeLm::Connection.post_json({ method: 'limelm.pkey.removeTag', pkey_id: @id, tag: tag })
      true
    end

    def details
      response = LimeLm::Connection.post_json({ method: 'limelm.pkey.getDetails', pkey_id: @id })
      self.send(:assign_properties, response['pkey'])
    end

    def destroy!
      LimeLm::Connection.post_json({ method: 'limelm.pkey.delete', pkey_id: @id })
      true
    end

    def toggle_revoke!
      revoke = @revoked ? 'false' : 'true'
      LimeLm::Connection.post_json({ method: 'limelm.pkey.revoke', pkey_id: @id, revoke: revoke })
      @revoked = !@revoked
    end

    def update(params)
      id if @id.nil?
      LimeLm::Connection.post_json({ method: 'limelm.pkey.setDetails', pkey_id: @id }.merge!(params))
    end

    private

    def assign_properties(hash)
      hash        = LimeLm::Utils.stringify_keys(hash)
      @id         = hash['id']
      @key        = hash['key']
      @version_id = hash['version_id']
      @email      = hash['email']
      @revoked    = hash['revoked'] || false
      @properties = hash
    end
  end
end
