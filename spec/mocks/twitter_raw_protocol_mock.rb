require "csv"
require "easy/mock"

class TwitterRawProtocolMock
  class << self
    def catalog
      @catalog = @catalog || OpenStruct.new(
        "TwitterLink" => TwitterLinkMock,
        "TwitterTarget" => TwitterTargetMock,
        "TwitterRawProfile" => TwitterRawProfileMock,
        "TwitterTouch" => TwitterTouchMock
      )
    end
  end
end

class TwitterLinkMock

  include Easy::Mock::ObjectMock
  extend Easy::Mock::CollectionMock

  set_model_class TwitterLinkMock

  attr_accessor :screen_name1, :screen_name2, :kind, :first_seen, :last_seen

end

class TwitterTargetMock

  include Easy::Mock::ObjectMock
  extend Easy::Mock::CollectionMock

  set_model_class TwitterTargetMock

  attr_accessor :screen_name, :id

end

class TwitterRawProfileMock
  include Easy::Mock::ObjectMock
  extend Easy::Mock::CollectionMock

  set_model_class TwitterRawProfileMock

  attr_accessor :screen_name, :id,
    :protected, :verified, :muting, :suspended,
    :geo_enabled, :time_zone, :lang,
    :description, :uri, :website_uris, :status,
    :created_at,

    :first_seen, :last_seen,

    :not_found,

    ### 1-N
    :screen_names_history,
    :suspension_history,
    :protected_history,
    :geo_enabled_history,
    :description_history,
    :time_zone_history

end

class TwitterTouchMock
  include Easy::Mock::ObjectMock
  extend Easy::Mock::CollectionMock

  set_model_class TwitterTouchMock

  KIND = [:fav, :rt, :mention, :reply]

  attr_accessor :tweet_id, :origin, :destination,
    :kind,
    :first_seen, :last_seen
end