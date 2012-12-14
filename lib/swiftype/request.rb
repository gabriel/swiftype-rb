require 'json'

module Swiftype
  module Request
    def get(path, params={}, options={})
      request(:get, path, params, options)
    end

    def delete(path, params={}, options={})
      request(:delete, path, params, options)
    end

    def post(path, params={}, options={})
      request(:post, path, params, options)
    end

    def put(path, params={}, options={})
      request(:put, path, params, options)
    end

    private
    def request(method, path, params, options)
      params.merge!({:auth_token => Swiftype.api_key}) if Swiftype.api_key
      response = connection.send(method) do |request|
        case method.to_sym
        when :delete, :get
          request.url(path, params)
        when :post, :put
          request.headers['Content-Type'] = 'application/json'
          request.path = path
          request.body = ::JSON.dump(params) unless params.empty?
        end

        request.options[:timeout] = 120
        request.options[:open_timeout] = 5
      end
      options[:raw] ? response : response.body
    end
  end
end
