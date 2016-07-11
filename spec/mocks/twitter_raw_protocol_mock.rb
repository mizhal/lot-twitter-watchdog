require "csv"

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

module ObjectMock

  def initialize(data = {})
    data.each{|k, v| send("#{k}=", v)}
  end

  def save
    ## doesnt do anything, all objects are in memory, don't need to 
    ## save state
  end

  def get_seteable_fields
    methods.select{|x| x.to_s =~ /^[a-zA-Z_0-9]*[=]$/}.map{|x| x.to_s.slice(0..-2)}
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

    def exists? filter
      self.find_by(filter).any?
    end

    def set_model_class model_class
      @model_class = model_class
    end

    def destroy_all
      @backend = []
    end

    def list_seteable_fields 
      instance_methods.select{|x| x.to_s =~ /^[a-zA-Z_0-9]*[=]$/}.map{|x| x.to_s.slice(0..-2)}
    end

    def export_to_csv filename
      fields = list_seteable_fields
      CSV.open(filename, "w", :col_sep => ";", :force_quotes => true) do |csv|
        csv << fields
        all.each do |instance|
          csv << fields.map{|field| instance.send(field)}
        end
      end
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

class TwitterTouchMock
  include ObjectMock
  extend CollectionMock

  set_model_class TwitterTouchMock

  KIND = [:fav, :rt, :mention, :reply]

  attr_accessor :tweet_id, :origin, :destination,
    :kind,
    :first_seen, :last_seen
end