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

      # Replace this retry stuff with conn.request :retry middleware when that comes out (in 0.9?).
      retries = 2
      begin
        response = connection.send(method) do |request|
          case method.to_sym
          when :delete, :get
            request.url(path, params.dup)
          when :post, :put
            request.headers['Content-Type'] = 'application/json'
            request.path = path
            request.body = ::JSON.dump(params) unless params.empty?
          end

          request.options[:timeout] = options[:timeout] || 30
          request.options[:open_timeout] = options[:open_timeout] || 5
        end

        options[:raw] ? response : response.body
      rescue Errno::ETIMEDOUT, Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed,
          Swiftype::UnexpectedHTTPException => e
        if retries > 0
          retries -= 1
          retry
        end
        raise
      end
    end
  end
end
