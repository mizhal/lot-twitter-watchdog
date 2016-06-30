class TwitterRawProtocolMock
  class << self
    def catalog
      @catalog = @catalog || OpenStruct.new(
        "TwitterLink" => TwitterLinkMock,
        "TwitterTarget" => TwitterTargetMock
      )
    end
  end
end

module ObjectMock
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
      @backend
    end

    def count
      @backend.count
    end

    def find_by filter
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

  def initialize data
    data.each{|k, v| send("#{k}=", v)}
  end

end

class TwitterTargetMock

  include ObjectMock
  extend CollectionMock

  set_model_class TwitterTargetMock

  attr_accessor :screen_name

  def initialize data
    data.each{|k, v| send("#{k}=", v)}
  end

end