module Rails
  module AddOns
    module WidgetHelper
      def render_widget(name, options = {}, &block)
        klass = "#{name}_widget".camelize.classify.constantize
        klass.new(self, options, &block).render
      end
    end
  end
end
