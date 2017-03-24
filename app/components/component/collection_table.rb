module Component
  class CollectionTable < Base
    def initialize(*args)
      super
      @columns        = {}
      @collection     = @options.delete(:collection)
      @resource_class = @collection.first.class
    end

    def column(name, options = {}, &block)
      options.reverse_merge!(block: block) if block_given?
      @columns[name] = options
    end

    private

    def table
      self
    end

    def view_locals
      {
        columns:        @columns,
        collection:     @collection,
        resource_class: @resource_class
      }
    end
  end
end