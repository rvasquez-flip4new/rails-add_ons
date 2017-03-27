module ResourcesController
  class Base < ::FrontendController
    layout 'rails/add_ons/application'

    module RestActions
      extend ActiveSupport::Concern

      included do
        respond_to :html
        responders :flash
        
        if respond_to?(:before_action)
          before_action :load_collection, only: [:index]
          before_action :load_resource, only: [:show, :edit]
          before_action :initialize_resource, only: [:new]
          before_action :initialize_resource_for_create, only: [:create]
        else
          before_filter :load_collection, only: [:index]
          before_filter :load_resource, only: [:show, :edit]
          before_filter :initialize_resource, only: [:new]
          before_filter :initialize_resource_for_create, only: [:create]
        end
      end

      def index; end
      def new; end
      def show; end
      def edit; end
      
      def create
        @resource.save
        respond_with @resource, flash_now: false, location: after_create_location.call(self)
      end

      private

      def after_create_location
        ->(controller) { resource_path(@resource) }
      end

      def load_collection
        @collection = resource_class.all
      end

      def load_resource
        @resource = resource_class.find(params[:id])
      end

      def initialize_resource
        @resource = resource_class.new
      end

      def initialize_resource_for_create
        @resource = resource_class.new(permitted_params)
      end

      def permitted_params
        raise "not implemented"
      end
    end

    module Resources
      extend ActiveSupport::Concern
      
      included do
        helper_method :resource_class
      end

      def resource_class
        self.class.resource_class
      end
    end

    module RestResourceUrls
      extend ActiveSupport::Concern

      included do
        helper_method :new_resource_path
        helper_method :collection_path
        helper_method :resource_path
        helper_method :edit_resource_path
      end

      private

      def new_resource_path
        url_for(action: :new, only_path: true)
      end

      def collection_path
        url_for(action: :index, only_path: true)
      end

      def resource_path(resource)
        url_for(action: :show, id: resource, only_path: true)
      end

      def edit_resource_path(resource)
        url_for(action: :edit, id: resource, only_path: true)
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
          resource_name: resource_class.model_name.human(count: 1),
          collection_name: resource_class.model_name.human(count: 2)
        }
      end
    end

    module LocationHistory
      extend ActiveSupport::Concern

      included do
        before_action :store_location
      end

      private

      def store_location
        session[:history][Time.zone.now] = request.referer
      end

      def location_history
        session[:history] ||= {}
      end

      def last_location
        location_history.sort.first.try(:last)
      end
    end

    include RestActions
    include Resources
    include RestResourceUrls
    include ResourceInflections
    include LocationHistory
  end
end