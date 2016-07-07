module Lot
  module TwitterWatchdog

    class TwitterTouchGraphGenerator < IWatchdogTask

      attr_accessor :client, :logger

      def initialize catalog, twitter_client, limit_iterations = nil
        @client = twitter_client
        @catalog = catalog
        @stop = false
      end

      def execute
        count = 0
        @catalog.TwitterTarget.all.each do |target|
          
          break if @stop
          
          break if @limit && count >= @limit

          scan_timeline(target) do
            count += 1
          end

          yield
          
          break if @limit && count >= @limit

          scan_favorites(target) do
            count += 1
          end

          yield
        end

      end

      def stop
        @stop = true
      end

      private

      def scan_timeline user 

        timeline = @client.user_timeline(user.id)

        timeline.each do |tweet|

          if tweet.retweet? 
            if is_known?(tweet, user, :rt)
              touch(tweet, user, :rt)
            else
              create(tweet, user, :rt)
            end
          elsif tweet.reply?
            if is_known?(tweet, user, :reply)
              touch(tweet, user, :reply)
            else
              create_reply(tweet, user)
            end
          end

          scan_mentions(tweet, user)

          yield
        end
      end

      def scan_favorites user
        faves = @client.favorites user

        faves.each do |fav|
          if is_known? fav, user, :fav
            touch(fav, user, :fav)
          else
            create(fav, user, :fav)
          end

          yield
        end

      end

      def scan_mentions tweet, user
        tweet.user_mentions.each do |mention|
          if is_known? tweet, user, :mention ## there are many
            touch tweet, user, :mention ## there are many mentions with this rule
          else
            create_mention(tweet, user, mention)
          end
        end
      end

      def is_known? tweet, user, kind
        @catalog.TwitterTouch.exists?(tweet_id: tweet.id, origin: user.id, kind: kind)
      end

      def touch tweet, user, kind
        @catalog.TwitterTouch.find_by(tweet_id: tweet.id, origin: user.id, kind: kind)
          .each do |tt|
            tt.first_seen ||= DateTime.now
            tt.last_seen = DateTime.now
          end
      end

      def create tweet, user, kind
        @catalog.TwitterTouch.create(
          tweet_id: tweet.id,
          origin: user.id,
          destination: tweet.user.id, 
          kind: kind,
          first_seen: DateTime.now,
          last_seen: DateTime.now
        )
      end

      def create_reply tweet, user
        @catalog.TwitterTouch.create(
          tweet_id: tweet.id,
          origin: user.id,
          destination: tweet.in_reply_to_user_id, 
          kind: kind,
          first_seen: DateTime.now,
          last_seen: DateTime.now
        )
      end

      def create_mention tweet, user, mention
        @catalog.TwitterTouch.create(
          tweet_id: tweet.id,
          origin: user.id,
          destination: mention.id, 
          kind: :mention,
          first_seen: DateTime.now,
          last_seen: DateTime.now
        )
      end
    end

  end
end