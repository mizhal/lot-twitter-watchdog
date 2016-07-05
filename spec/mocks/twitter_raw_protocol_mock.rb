class TwitterRawProtocolMock
  class << self
    def catalog
      @catalog = @catalog || OpenStruct.new(
        "TwitterLink" => TwitterLinkMock,
        "TwitterTarget" => TwitterTargetMock,
        "TwitterRawProfile" => TwitterRawProfileMock
      )
    end
  end
end

module ObjectMock

  def initialize data
    data.each{|k, v| send("#{k}=", v)}
  end

  def save
    ## doesnt do anything, all objects are in memory, don't need to 
    ## save state
  end
end

module CollectionMock

    def create data
      ensure_backend_mock

      new_ = @model_class.new(data)
      @backend << new_

      new_
    end

    def all 
      ensure_backend_mock
      @backend
    end

    def count
      ensure_backend_mock
      @backend.count
    end

    def find_by filter
      ensure_backend_mock
      ## this is not efficient, only meant for testing
      @backend.select{ |obj| 
        filter.all?{ |k,v| obj.send(k) == v }
      }
    end

    def set_model_class model_class
      @model_class = model_class
    end

    def destroy_all
      @backend = []
    end

    private

    def ensure_backend_mock
      @backend = @backend || []
    end

end

class TwitterLinkMock

  include ObjectMock
  extend CollectionMock

  set_model_class TwitterLinkMock

  attr_accessor :screen_name1, :screen_name2, :kind, :first_seen, :last_seen

end

class TwitterTargetMock

  include ObjectMock
  extend CollectionMock

  set_model_class TwitterTargetMock

  attr_accessor :screen_name, :id

<<<<<<< Updated upstream
  def initialize data
    data.each{|k, v| send("#{k}=", v)}
  end
=======
end

class TwitterRawProfileMock
  include ObjectMock
  extend CollectionMock

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
>>>>>>> Stashed changes

end

class TwitterRawProfileMock
  include ObjectMock
  extend CollectionMock

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