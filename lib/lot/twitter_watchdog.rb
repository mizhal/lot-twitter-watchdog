require "twitter"

require "lot/twitter_watchdog/version"

require "lot/twitter_watchdog/i_watchdog_task"
require "lot/twitter_watchdog/twitter_control"
require "lot/twitter_watchdog/twitter_graph_generator"
require "lot/twitter_watchdog/twitter_touch_graph"
require "lot/twitter_watchdog/watchdog"

module Lot
  module TwitterWatchdog

    SLEEP_TIME = 3

    ## FACADE
    def self.get_watchdog
      if(!has_conf)
        raise "TwitterWatchdog not configured, cannot start"
      end
      
      return Watchdog.new(get_client)
    end
    ## END: FACADE

    ## CONFIG
    def self.configure
      yield get_conf
      initialize_twitter_api
    end
    
    class << self
      attr_accessor :config, :api_client

      private 

      def get_conf
        @config ||= Config.new
        @config
      end

      def has_conf
        @config.present?
      end

      def initialize_twitter_api
        @api_client = TwitterControl.new @config.api_secrets_file, @config.environment
      end

      def get_client
        @api_client
      end
    end

    class Config
      attr_accessor :api_secrets_file
      attr_accessor :environment
    end
    ## END: CONFIG

  end
end
