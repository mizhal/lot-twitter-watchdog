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

    ## CONFIG
    def self.configure
      yield get_conf
      initialize_twitter_api
      start_watchdog
    end
    
    class << self
      attr_accessor :config, :api_client, :watchdog

      ## FACADE
      def get_watchdog
        if(!has_conf)
          raise "TwitterWatchdog not configured, can't create watchdog instance"
        end
        
        return @watchdog
      end
      ## END: FACADE

      private 

      def get_conf
        @config ||= Config.new
        @config
      end

      def has_conf
        @config.present?
      end

      def initialize_twitter_api
        @api_control = TwitterControl.new @config.api_secrets_file, @config.environment
        unless @api_control.smoke_test
          raise "Twitter api client not connected due to misconfiguration"
        end
      end

      def get_client
        @api_control.client
      end

      def get_logger
        @config.logger
      end

      def start_watchdog
        ## set common twitter api client
        @config.tasks.each do |task|
          task.client = get_client
        end
        ## set logger
        @config.tasks.each do |task|
          task.logger = get_logger
        end
        @watchdog = Watchdog.new @config.tasks
        @watchdog.logger = get_logger
        @watchdog.run
      end
    end

    class Config
      attr_accessor :api_secrets_file, :environment,
        :logger, 
        :tasks ## list, contains IWatchdogTask instances
    end
    ## END: CONFIG

  end
end
