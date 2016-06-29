require "twitter"

module Lot
  module TwitterWatchdog
    class TwitterControl
      attr_reader :client

      def initialize config_file, environment
        open_config config_file
        
        @client = Twitter::REST::Client.new do |config|
          config.consumer_key = @config["twitter-api"][environment]["consumer_key"]
          config.consumer_secret = @config["twitter-api"][environment]["consumer_secret"] 
          config.access_token = @config["twitter-api"][environment]["access_token"]
          config.access_token_secret = @config["twitter-api"][environment]["access_token_secret"]
        end
      end

      def open_config conf_file
        @config = YAML.load(open(conf_file){|f| f.read})
      end
    end
  end
end