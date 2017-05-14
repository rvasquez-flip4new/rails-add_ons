module Rails
  module AddOns
    module TableHelper
      def collection_table(options = {}, &block)
        Component::CollectionTable.new(self, options, &block).perform
      end

      def resource_table(options = {}, &block)
        Component::ResourceTable.new(self, options, &block).perform
      end

      def sort_link(column_name, title, options = {})
        return title if options === false
        SortLink.new(self, column_name, title, options).perform
      end

      class SortLink
        def initialize(view_context, column_name, title, options)
          default_options = {}

          if options === true
            @options = default_options
          else
            @options = options.reverse_merge(default_options)
          end

          @view_context = view_context
          @column_name  = column_name
          @title        = title

          if h.params[:sort_direction].present?
            @sort_direction = (h.params[:sort_direction].to_sym == :asc) ? :desc : :asc
          else
            @sort_direction = :asc
          end
        end

        def perform
          h.link_to(@title, h.url_for(sort_by: @column_name, sort_direction: @sort_direction))
        end

        private

        def h
          @view_context
        end
      end
    end
  end
end