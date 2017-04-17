module Rails
  module AddOns
    class WidgetsController < ApplicationController
      def remote_render
        widget_name, action = *params[:name].split("#")
        render plain: widget_name.camelize.constantize.new(view_context).render(action)
      end
    end
  end
end
