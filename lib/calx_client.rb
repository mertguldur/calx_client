module CalX
  class Error < StandardError; end
  class ServerError < Error; end
  class ClientError < Error; end
  class AuthenticationError < ClientError; end

  class Client
    def initialize(access_id, secret_key, options = {})
      @access_id = access_id
      @secret_key = secret_key
      @host = host(options)
    end

    def authorize(user_id)
      post('/app_authorization_requests', user_id: user_id)
    end

    def events(user_id, params = {})
      get("/users/#{user_id}/events", params)
    end

    def event(event_id)
      get("/events/#{event_id}")
    end

    def create_event(user_id, params)
      post("/users/#{user_id}/events", params)
    end

    def update_event(event_id, params)
      put("/events/#{event_id}", params)
    end

    def delete_event(event_id)
      delete("/events/#{event_id}")
    end

    private

    def get(request_uri, params = {})
      request_uri += "?#{encode_params(params)}" unless params.nil?
      uri = URI(@host + request_uri)
      request = Net::HTTP::Get.new(uri.request_uri)
      request(uri, request)
    end

    def post(request_uri, params)
      uri = URI(@host + request_uri)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.form_data = params
      request(uri, request)
    end

    def put(request_uri, params)
      uri = URI(@host + request_uri)
      request = Net::HTTP::Put.new(uri.request_uri)
      request.form_data = params
      request(uri, request)
    end

    def delete(request_uri)
      uri = URI(@host + request_uri)
      request = Net::HTTP::Delete.new(uri.request_uri)
      request(uri, request)
    end

    def request(uri, request)
      signed_request = ApiAuth.sign!(request, @access_id, @secret_key)
      response = http(uri).request(signed_request)
      parse_response(response)
    end

    def parse_response(response)
      case response
      when Net::HTTPNoContent
        :no_content
      when Net::HTTPSuccess
        parse_success_response(response)
      when Net::HTTPUnauthorized
        raise AuthenticationError.new(error_response_message(response, uri))
      when Net::HTTPClientError
        raise ClientError.new(error_response_message(response, uri))
      when Net::HTTPServerError
        raise ServerError.new(error_response_message(response, uri))
      else
        raise Error.new(error_response_message(response, uri))
      end
    end

    def parse_success_response(response)
      if response['Content-Type'].split(';').first == 'application/json'
        JSON.parse(response.body)
      else
        response.body
      end
    end

    def error_response_message(response, uri)
      message = "#{response.code} response from #{uri.host}"
      message + " | Response body: #{JSON.parse(response.body)}" if response.body.present?
    end

    def http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.is_a?(URI::HTTPS)
      http
    end

    def host(options = {})
      (options[:host] || 'http://localhost:3000') + '/api/v1'
    end

    def encode_params(params)
      params.flat_map do |k, vs|
        Array(vs).map { |v| "#{escape_component(k)}=#{escape_component(v)}" }
      end.join('&')
    end

    def escape_component(component)
      CGI.escape(component.to_s)
    end
  end
end
