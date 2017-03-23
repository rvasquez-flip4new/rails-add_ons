module Component
  class ResourceTable < Base
    def initialize(*args)
      super
      @rows           = {}
      @resource       = @options.delete(:resource)
      @resource_class = @resource.class
    end

    def row(name, options = {}, &block)
      options.reverse_merge!(block: block) if block_given?
      @rows[name] = options
    end

    private

    def view_locals
      {
        rows:           @rows,
        resource:       @resource,
        resource_class: @resource_class
      }
    end
  end
end