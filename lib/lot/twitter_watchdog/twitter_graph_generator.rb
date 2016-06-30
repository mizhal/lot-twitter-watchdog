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
            link = catalog.TwitterLink.find_by(
              screen_name1: nick, 
              screen_name2: result.username,
              kind: "follow"
            )
            unless link.nil?
              link = catalog.TwitterLink.create(
                screen_name1: nick, 
                screen_name2: result.username,
                kind: "follow"
              )
            end
            yield
          end

          @client.followers(nick).each do |result|
            link = catalog.TwitterLink.find_by(
              screen_name1: result.username, 
              screen_name2: nick,
              kind: "follow"
            )
            unless link.nil?
              link = catalog.TwitterLink.create(
                screen_name1: result.username, 
                screen_name2: nick,
                kind: "follow"
              )
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