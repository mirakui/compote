require 'time'
require 'uri'
require 'openssl'
require 'base64'
require 'nokogiri'

module Compote
  module Amazon
    module Strategy
      class Base
        ENDPOINT = 'webservices.amazon.co.jp'
        REQUEST_URI = '/onca/xml'

        def initialize(fetcher:nil)
          @fetcher = fetcher
        end

        def build(args={})
          params = build_params args

          query = params_to_query params
          signature = query_to_signature query

          URI::HTTPS.build(
            host: ENDPOINT,
            path: REQUEST_URI,
            query: "#{query}&Signature=#{signature}",
          )
        end

        def execute(args={})
          body = request args
          parse_body_xml body
        end

        def request(args={})
          uri = build args
          @fetcher.fetch uri
        end

        def parse_as_xml(body)
          body_xml = Nokogiri::XML body
          parse body_xml
        end

        def params(args={})
          raise 'must be overridden'
        end

        def parse(args={})
          raise 'must be overridden'
        end

        private

        def build_params(args)
          {
            'Service' => 'AWSECommerceService',
            'AWSAccessKeyId' => ENV['AWS_ACCESS_KEY_ID'],
            'AssociateTag' => ENV['AMAZON_ASSOCIATE_TAG'],
            'SearchIndex' => 'Books',
            'Timestamp' => Time.now.gmtime.iso8601,
          }.merge params(args)
        end

        def params_to_query(params)
          canonical_query_string = params.sort.map do |key, value|
            [escape(key.to_s), escape(value.to_s)].join('=')
          end.join('&')
        end

        def query_to_signature(query)
          string_to_sign = ['GET', ENDPOINT, REQUEST_URI, query].join("\n")
          @sha256 ||= OpenSSL::Digest.new('sha256')

          sig = Base64.encode64(
            OpenSSL::HMAC.digest(
              @sha256,
              ENV['AWS_SECRET_ACCESS_KEY'],
              string_to_sign
            )
          ).strip
          escape sig
        end

        def escape(str)
          @uri_unreserved_regex ||= Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")
          URI.escape(str, @uri_unreserved_regex)
        end
      end
    end
  end
end
