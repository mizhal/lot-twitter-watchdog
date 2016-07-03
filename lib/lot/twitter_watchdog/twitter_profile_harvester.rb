module Lot
  module TwitterWatchdog
    class TwitterProfileHarvester < IWatchdogTask

      attr_accessor :client

      def initialize catalog, twitter_client, limit_iterations = nil
        @client = twitter_client
        @catalog = catalog
        @stop = false
        @limit = limit_iterations
      end

      def execute
        count = 0
        @catalog.TwitterTarget.all.each do |target|

          break if @stop

          break if count >= @limit

          profile_data = @catalog.TwitterRawProfile
            .find_by(screen_name: target.screen_name)
            .first

          if profile_data.nil?
            profile_data = @catalog.TwitterRawProfile.new
          end

          begin
            twitter_user = @client.user target.screen_name
          rescue Twitter::Error::NotFound => e
            profile_data.not_found = true

            next
          end

          copy_data(twitter_user, profile_data)

          touch(profile_data)

          profile_data.save

          count += 1

          yield

        end
      end

      def stop
        @stop = true
      end

      private

      def touch(profile)
        profile.first_seen ||= DateTime.now
        profile.last_seen = DateTime.now
      end

      def is_blocking_api_user?(profile)
        profile.tweet_count > 0 && profile.tweet.nil?
      end

      def copy_data tw, db 
        db.screen_name = tw.screen_name
        db.id = tw.id
        db.protected = tw.protected?
        db.verified = tw.verified?
        db.muting = tw.muting? 
        db.suspended = tw.suspended?
        db.geo_enabled = tw.geo_enabled?
        db.time_zone = tw.time_zone 
        db.lang = tw.lang
        db.description = tw.description
        db.uri = tw.uri
        db.website_uris = tw.website_uris 
        db.status = tw.status
        db.created_at = db.created_at
      end
    end
  end
end