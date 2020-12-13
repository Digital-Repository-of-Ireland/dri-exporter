require 'net/http'
require 'uri'
require 'json'

module Dri::Exporter
  class DriService

    def self.parse(url, object_ids)
      response = dri_response(url, object_ids)
      JSON.parse(response)
    end

    private
      class << self
        def dri_response(url, object_ids)
          request_params = { objects: object_ids.map { |id| { pid: id } } }

          uri = URI.parse(url)
          response = Net::HTTP.new(uri.host, uri.port)
          http = Net::HTTP.new(uri.host, uri.port)

          if uri.scheme == "https"
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end

          request = Net::HTTP::Post.new(
            uri.request_uri,
            {'Content-Type': 'application/json'}
          )
          request.body = request_params.to_json
          http.request(request).body
        end
      end
  end
end
