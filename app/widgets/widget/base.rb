module Widget
  class Base
    def self.default_action
      :show
    end

    def initialize(view_context, options = {}, &block)
      @view_context = view_context
      @options = options
      @block = block
      @view_options = {}
    end

    def render(action = nil)
      action ||= self.class.default_action
      send(action)
      @view_context.render(partial_path(action), view_locals)
    end

    private

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
  end
end