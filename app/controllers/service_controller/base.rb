module ServiceController
  class Base < ::FrontendController
    layout 'rails/add_ons/application'

    module RestActions
      extend ActiveSupport::Concern

      included do
        include ActionController::MimeResponds
        
        respond_to :html
        responders :flash
        
        if respond_to?(:before_action)
          before_action :initialize_service, only: [:new]
          before_action :initialize_service_for_create, only: [:create]
        else
          before_filter :initialize_service, only: [:new]
          before_filter :initialize_service_for_create, only: [:create]
        end
      end


      def new; end
      
      def create
        @response = @resource.perform
        if @response.success?
          render :create
        else
          render :new
        end
      end

      private

      def initialize_service
        @resource = service_class.new
      end

      def initialize_service_for_create
        @resource = service_class.new(permitted_params)
      end

      def permitted_params
        raise "not implemented"
      end
    end

    module Service
      extend ActiveSupport::Concern
      
      included do
        helper_method :service_class
      end

      def service_class
        self.class.service_class
      end
    end

    module RestResourceUrls
      extend ActiveSupport::Concern

      included do
        helper_method :new_resource_path
        helper_method :create_resource_path
      end

      private

      def new_resource_path
        url_for(action: :new, only_path: true)
      end

      def create_resource_path
        url_for(action: :create, only_path: true)
      end
    end

    module ResourceInflections
      extend ActiveSupport::Concern

      included do
        helper_method :inflections
      end

      private

      def inflections
        {
          service_name: service_class.model_name.human
        }
      end
    end

    module LocationHistory
      extend ActiveSupport::Concern

      included do
        if respond_to?(:before_action)
          before_action :store_location
        else
          before_filter :store_location
        end
      end

      private

      def store_location
        truncate_location_history(9)
        location_history[Time.zone.now] = request.referer
      end

      def location_history
        session[:location_history] ||= {}
      end

      def last_location
        location_history.sort.last.try(:last)
      end

      def truncate_location_history(count = 0)
        return if location_history.size <= count
        session[:location_history] = session[:location_history].sort.last(count).to_h
      end
    end

    include Service
    include RestActions
    include RestResourceUrls
    include ResourceInflections
    include LocationHistory
  end
end