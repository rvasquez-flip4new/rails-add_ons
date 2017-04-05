module Rails
  module AddOns
    module TableHelper
      def collection_table(options = {}, &block)
        Component::CollectionTable.new(self, options, &block).perform
      end

      def resource_table(options = {}, &block)
        Component::ResourceTable.new(self, options, &block).perform
      end
    end
  end
end