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

class ObjectMock
end

module CollectionMock

    def create data
      ensure_backend_mock

      @backend << @model_class.new(data)
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

  extend CollectionMock

  set_model_class TwitterLinkMock

  attr_accessor :screen_name1, :screen_name2, :kind

  def initialize data
    data.each{|k, v| send("#{k}=", v)}
  end

end

class TwitterTargetMock

  extend CollectionMock

  set_model_class TwitterTargetMock

  attr_accessor :screen_name

  def initialize data
    data.each{|k, v| send("#{k}=", v)}
  end

end