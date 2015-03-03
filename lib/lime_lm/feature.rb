module LimeLm
  class Feature
    attr_reader :id
    attr_reader :name
    attr_reader :type
    attr_reader :ta_readable
    attr_reader :required
    attr_reader :description  	

    def initialize(hash)
      self.send(:assign_properties, hash)
    end

    class << self
      def create(params={})
        version_id = params.delete(:version_id) { LimeLm.config[:version_id] }

        response = LimeLm::Connection.post_json({ method: 'limelm.feature.add', version_id: version_id }.merge!(params))
        additional_info = LimeLm::Utils.stringify_keys(params)
        additional_info['type'] = 'string' unless additional_info['type'] 
        additional_info['required'] = 'true' unless additional_info['required']
        additional_info['ta_readable'] = 'true' unless additional_info['ta_readable']

        new(response['feature'].merge!(additional_info))
      end

      def all(params={})
      	version_id = params.delete(:version_id) { LimeLm.config[:version_id] }
        
        response = LimeLm::Connection.post_json({ method: 'limelm.feature.getAll', version_id: version_id})
        response['fields']['field'].map { |f| new(f) }
      end
    end

    def update!(params={})
      #TODO
    end

    def destroy!
      #TODO
    end

    private

    def assign_properties(hash)
      @id          = hash['id']
      @name        = hash['name']
      @type        = hash['type']
      @ta_readable = hash['ta_readable'] == 'true'
      @required    = hash['required'] == 'true'
      @description = hash['description']
    end
  end
end