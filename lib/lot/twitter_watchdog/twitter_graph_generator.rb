module Lot
  module TwitterWatchdog

    class TwitterGraphGenerator < IWatchdogTask

      def initialize(client, catalog)
        @client = client
        @catalog = catalog
        @stop = false
      end

      def execute()
        
        pack_of_nicks = catalog.TwitterTarget.all

        pack_of_nicks.each do |nick|

          break if @stop

          @client.following(nick).each do |result|
            link = catalog.TwitterLink.find_by_first_and_second(nick, result.username)
            unless link.nil?
              link = catalog.TwitterLink.create(first: nick, second: result.username)
            end
            yield
          end

          @client.followers(nick).each do |result|
            link = catalog.TwitterLink.find_by_first_and_second(result.username, nick)
            unless link.nil?
              link = catalog.TwitterLink.create(second: nick, first: result.username)
            end
            yield
          end

        end

      end

      def stop
        @stop = true
      end

    end
  end
end