module Api
  class Cache
    def self.cache(options = {}, &block)
      instance = new(options = {})
      instance.prepare_cache(&block)
      instance
    end

    def initialize(options = {}, &block)
    end

    def prepare_cache(&block)
      @cachable = block
    end

    def method_missing(m, *args, &block)
      key = "#{m}-#{args.to_json}-#{block.to_json}"
      # raise key
      output = @cachable.call.send(m, *args, &block)
      # raise output.inspect
      output
    end 
  end
end