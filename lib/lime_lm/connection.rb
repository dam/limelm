module LimeLm
  class Connection
  	include HTTParty
  	base_uri 'https://wyday.com/limelm/api/rest/'

  	class << self
  	  def post_json(params)
        raise LimeLm::InvalidParams, 'LimeLM api expecting a method parameter' unless params[:method]
  	  	
  	    url = generate_url(params)
  	    response = post(url)

  	    parsed_response = JSON.parse($1) if response.body =~ /jsonLimeLMApi\((.*)\)/
  	    raise LimeLm::ParseResponse, "Unable to parse API response: #{response.body }" unless parsed_response
  	    
  	    raise LimeLm::ApiError, "#{parsed_response['code']}: #{parsed_response['message']}" unless parsed_response['stat'] == 'ok'
  	    parsed_response
  	  end	

  	  protected

  	  def generate_url(params)
  	    params[:api_key] = LimeLm.config[:api_key]
  	    params[:format] = :json
  	  	
  	    query = params.map { |k,v| "#{k}=#{v}" }.join('&') 
  	    '?' + query
  	  end
  	end
  end
end