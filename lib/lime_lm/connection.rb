module LimeLm
  class Connection
  	include HTTParty
  	base_uri 'https://wyday.com/limelm/api/rest/'

  	class << self
  	  def post_json(params)
        raise LimeLm::InvalidParams, 'LimeLM api expecting a method parameter' unless params[:method]
  	  	
        params[:api_key] = LimeLm.config[:api_key]
        params[:format] = :json

  	    response = post('', query: params)

  	    parsed_response = JSON.parse($1) if response.body =~ /jsonLimeLMApi\((.*)\)/
  	    raise LimeLm::ParseResponse, "Unable to parse API response: #{response.body }" unless parsed_response
  	    
  	    raise LimeLm::ApiError, "#{parsed_response['code']}: #{parsed_response['message']}" unless parsed_response['stat'] == 'ok'
  	    parsed_response
  	  end	
  	end
  end
end