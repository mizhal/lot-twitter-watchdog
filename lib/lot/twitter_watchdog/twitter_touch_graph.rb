module Lot
  module TwitterWatchdog

    class TwitterTouchGraphGenerator < IWatchdogTask

      attr_accessor :client, :logger

      def initialize client
        @client = client
      end

      def execute
      end

      def report
      end
    
    end

  end
end