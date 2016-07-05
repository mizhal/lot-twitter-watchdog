module Lot
  module TwitterWatchdog

    class Watchdog
      
      attr_accessor :logger

      def initialize tasks
        @tasks = tasks
      end

      def run
        @tasks.each do |task| 
          log_fatals_for task do 

            task.execute do
              sleep_for_api_limit
            end

          end
        end
      end

      def sleep_for_api_limit
        sleep Lot::TwitterWatchdog::SLEEP_TIME
      end

      def log_fatals_for task
        begin

          yield
        
        rescue Exception => e
          
          unless @logger.nil?
            @logger.fatal("#{task.class.to_s}:\n#{e.to_s}")
          else
            raise e 
          end

        end
      end

    end
  end
end