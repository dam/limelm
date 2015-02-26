module LimeLm
  class Key
    class << self
      def find(email, params={})
      	version_id = params.delete(:version_id) { LimeLm.config[:version_id] }

      	response = LimeLm::Connection.post_json({ method: 'limelm.pkey.find', version_id: version_id, email: email })
        response['pkeys']['pkey'] 
      end
    end  
  end
end