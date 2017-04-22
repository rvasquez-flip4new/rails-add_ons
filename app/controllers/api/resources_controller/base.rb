module Api
  module ResourcesController
    class Base < ::ApiController
      module RestActions
        extend ActiveSupport::Concern

        included do
          include ActionController::MimeResponds

          respond_to :json
          
          if respond_to?(:before_action)
            before_action :load_collection, only: [:index]
            before_action :load_resource, only: [:show, :update, :destroy]
            before_action :initialize_resource_for_create, only: [:create]
          else
            before_filter :load_collection, only: [:index]
            before_filter :load_resource, only: [:show, :update, :destroy]
            before_filter :initialize_resource_for_create, only: [:create]
          end
        end

        def index
          respond_to do |format|
            format.json { render json: @collection }
          end
        end

        def show
          respond_with(@resource)
        end

        def create
          respond_to do |format|
            if @resource.save
              format.json { render json: @resource, status: :created }
            else
              format.json { render json: { errors: @resource.errors.full_messages }, status: 422 }
            end
          end
        end

        def update
          respond_to do |format|
            if @resource.update_attributes(permitted_params)
              format.json { render json: @resource }
            else
              format.json { render json: { errors: @resource.errors.full_messages }, status: 422 }
            end
          end
        end

        def destroy
          @resource.destroy
          respond_to do |format|
            format.json { render json: @resource }
          end
        end

        private

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

        def resource_class
          self.class.resource_class
        end
      end

      module RestResourceUrls
        extend ActiveSupport::Concern

        included do
          helper_method :resource_path
        end

        private

        def resource_url(resource)
          url_for(action: :show, id: resource.to_param)
        end
      end

      include RestActions
      include Resources
      include RestResourceUrls
    end
  end
end
