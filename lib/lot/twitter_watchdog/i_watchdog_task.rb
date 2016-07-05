module Lot
  module TwitterWatchdog
  	class IWatchdogTask 
  		## this is completely unnecessary in Ruby, but documents
  		## code better, even though interfaces are not enforced
  		def execute
  		end

  		def stop
  		end

      def client
      end

      def client= c 
      end

      def logger
      end
      
      def logger= l
      end

      def with_log
        ## to be strict, an interface should not have implemented methods
        ## but I'm not going to be strict.
        unless @logger.nil?
          yield logger
        end
      end

  	end
  end
end