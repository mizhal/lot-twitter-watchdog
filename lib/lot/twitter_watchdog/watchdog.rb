module Lot
  module TwitterWatchdog

    class Watchdog
      
      def initialize tasks
        @tasks = tasks
      end

      def run
        @tasks.each do |task| 
          task.execute do
            sleep_for_api_limit
          end
        end
      end

      def sleep_for_api_limit
        sleep 3
      end

    end

  end
end