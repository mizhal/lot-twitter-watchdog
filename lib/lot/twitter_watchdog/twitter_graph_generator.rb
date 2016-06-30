module Lot
  module TwitterWatchdog

    class TwitterGraphGenerator < IWatchdogTask

      def initialize(client, catalog, limit_links = nil)
        @client = client
        @catalog = catalog
        @stop = false
        @limit_links = limit_links
      end

      def execute()
        
        pack_of_nicks = @catalog.TwitterTarget.all.map{|x| x.screen_name}

        pack_of_nicks.each do |nick|

          break if @stop
          
          count = 0
          @client.following(nick).each do |result|

            break if @limit_links && @limit_links <= count
              
            link = @catalog.TwitterLink.find_by(
              screen_name1: nick, 
              screen_name2: result.screen_name,
              kind: "follow"
            )
            unless link.nil?
              link = @catalog.TwitterLink.create(
                screen_name1: nick, 
                screen_name2: result.screen_name,
                kind: "follow"
              )
            end
            
            touch(link)

            yield

            count += 1
          end

          count = 0
          @client.followers(nick).each do |result|

            break if @limit_links && @limit_links <= count

            link = @catalog.TwitterLink.find_by(
              screen_name1: result.screen_name, 
              screen_name2: nick,
              kind: "follow"
            )
            unless link.nil?
              link = @catalog.TwitterLink.create(
                screen_name1: result.screen_name, 
                screen_name2: nick,
                kind: "follow"
              )
            end

            touch(link)

            yield

            count += 1
          end

        end

      end

      def touch link
        link.first_seen = DateTime.now if link.first_seen.nil?
        link.last_seen = DateTime.now
        
        link.save
      end

      def stop
        @stop = true
      end

    end
  end
end