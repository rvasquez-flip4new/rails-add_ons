module Widget
  class Base
    attr_accessor :view_context

    def self.default_action
      :show
    end

    def self.helper(helper)
      helpers << helper
    end

    def self.helpers
      @helpers ||= []
    end

    def initialize(view_context, options = {}, &block)
      options.reverse_merge!(frame: false, remote: false)

      @view_context = view_context
      @options      = options
      @block        = block
      @view_options = {}

      @remote = options.delete(:remote)
      @frame  = options.delete(:frame)

      add_helpers_to_view_context
    end

    def render(action = nil)
      action ||= self.class.default_action
      send(action)
      output = ""
      output << @view_context.content_tag(:div, class: widget_classes, id: dom_id, :'data-widget' => widget_name, :'data-widgetaction' => action, :'data-container' => container_dom_id) do
        @view_context.render(partial: '/widget/base/widget_controls', formats: [:html], locals: { dom_id: dom_id}) +
        @view_context.render(partial: partial_path(action), formats: [:html], locals: view_locals) unless @remote
      end
      output << remote_load_code(action) if @remote
      output.html_safe
    end

    private

    def widget_classes
      classes = ["widget", "widget-#{dom_id}"]
      classes << "widget-frame" if @frame
      classes
    end

    def add_helpers_to_view_context
      self.class.helpers.each do |helper|
        @view_context.class_eval { include helper }
      end
    end

    def remote_load_code(action)
      @view_context.render(partial: '/widget/base/remote_load_code', locals: { widget_dom_id: dom_id, widget_action: action, widget_name: widget_name})
    end

    def view_options
      { locals: view_locals }
    end

    def view_locals
      (instance_variables - excluded_instance_variables).each_with_object({}) do |var_name, memo|
        memo[var_name.to_s[1..-1].to_sym] = instance_variable_get(var_name)
      end
    end

    def excluded_instance_variables
      [:@view_context, :@options, :@block, :@view_options]
    end

    def partial_path(action)
      "#{self.class.name.underscore}/#{action}"
    end

    def widget_name
      self.class.name.underscore
    end


    def dom_id
      "#{container_dom_id}_#{widget_name.gsub('/', '_')}"
    end

    def container_dom_id
      @options[:container_name].try(:underscore) || 'default'
    end
  end
end