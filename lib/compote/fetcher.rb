require 'uri'
require 'net/http'

module Compote
  class Fetcher
    class RetryLimit < StandardError; end

    DEFAULT_INTERVAL = 1
    RETRY_INTERVALS = [1, 2, 4, 8, 16, 32, 64]

    def initialize
      @last_fetched_at = {}
    end

    def fetch(uri)
      uri = URI.parse uri unless uri.is_a?(URI)
      sleep_host_interval uri.host

      res = nil
      i = 0
      loop do
        res = Net::HTTP.get_response uri
        if res.code =~ /^5/
          sleep_retry_interval i
        else
          break
        end
        i += 1
      end
      res.body
    end

    def sleep_host_interval(host)
      return unless @last_fetched_at.has_key? host
      interval = DEFAULT_INTERVAL - (Time.now - @last_fetched_at[host])
      if inverval > 0
        Rails.logger.debug "waiting #{interval} secs for #{host}"
        sleep interval
      end
    end

    def sleep_retry_interval(phase)
      max = RETRY_INTERVALS.length

      if phase >= max
        raise RetryLimit, "retry limit exceeded: retried #{phase+1} times"
      end

      interval = RETRY_INTERVALS[phase]
      Rails.logger.debug "waiting #{interval} secs for retrying (#{phase+1}/#{max})"
      sleep interval
    end
  end
end
