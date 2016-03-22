module Sitemaps
  # Simple single purpose HTTP client
  module Fetcher
    class FetchError < StandardError; end
    class MaxRedirectError < StandardError; end

    @max_attempts = 10

    def self.fetch(uri)
      attempts = 0

      until attempts >= @max_attempts
        resp = Net::HTTP.get_response(uri)

        # on a good 2xx response, return the body
        if resp.code.to_s =~ /2\d\d/
          if resp.header["Content-Encoding"].blank? && uri.path =~ /\.gz$/
            return Zlib::GzipReader.new(StringIO.new(resp.body)).read
          else
            return resp.body
          end

        # on a 3xx response, handle the redirect
        elsif resp.code.to_s =~ /3\d\d/
          location = URI.parse(resp.header['location'])
          location = uri + resp.header['location'] if location.relative?

          uri       = location
          attempts += 1
          next

        # otherwise (4xx, 5xx) throw an exception
        else
          raise FetchError, "Failed to fetch URI, #{uri}, failed with response code: #{resp.code}"
        end
      end

      # if we got here, we ran out of attempts
      raise MaxRedirectError, "Failed to fetch URI #{uri}, redirected too many times" if attempts >= @max_attempts
    end
  end
end
