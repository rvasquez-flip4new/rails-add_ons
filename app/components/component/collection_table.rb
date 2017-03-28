module Component
  class CollectionTable < Base
    SIZE_MAP = {
      default: nil,
      small:   :sm
    }

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

    def timestamps
      column(:created_at)
      column(:updated_at)
    end

    def association(name, options = {}, &block)
      options.reverse_merge!(block: block) if block_given?
      @columns[name] = options
    end

    private

    def table
      self
    end

    def view_locals
      {
        columns:           @columns,
        collection:        @collection,
        resource_class:    @resource_class,
        table_css_classes: table_css_classes
      }
    end

    def striped?
      !!@options[:striped]
    end

    def responsive?
      !!@options[:responsive]
    end

    def inverse?
      !!@options[:inverse]
    end

    def bordered?
      !!@options[:bordered]
    end

    def hover?
      !!@options[:hover]
    end

    def size
      SIZE_MAP[@options[:size] || :default]
    end

    def table_css_classes
      classes = ['table']
      classes << 'table-bordered'   if bordered?
      classes << 'table-hover'      if hover?
      classes << 'table-inverse'    if inverse?
      classes << 'table-striped'    if striped?
      classes << 'table-responsive' if responsive?
      classes << "table-#{size}"    if size.present?
      classes
    end
  end
end