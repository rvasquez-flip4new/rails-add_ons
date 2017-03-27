module WidgetHelper
  def render_widget(name, options = {}, &block)
    klass = name.camelize.classify.constantize
    klass.new(self, options, &block).render
  end
end