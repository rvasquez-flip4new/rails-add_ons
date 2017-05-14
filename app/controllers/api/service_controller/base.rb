module Api
  module ServiceController
    class Base < ::ApiController
      module RestActions
        extend ActiveSupport::Concern

        included do
          include ActionController::MimeResponds

          respond_to :json
          
          if respond_to?(:before_action)
            before_action :initialize_service_for_create, only: [:create]
          else
            before_filter :initialize_service_for_create, only: [:create]
          end
        end

        def create
          @result = @service.perform
          respond_to do |format|
            if @result.success?
              format.json { render json: serialize_result(@result), status: :created }
            else
              format.json { render json: { errors: serialize_errors(@result.errors) }, status: 422 }
            end
          end
        end

        private

        def initialize_service_for_create
          # In rails 5 permitted_params is an instance of ActionController::Parameters.
          # Stragely, when calling #delete on it, it does not delete the key, so we have
          # to transform it into a hash first. 
          params_hash = permitted_params.try(:to_h).presence || permitted_params
          
          options = params_hash.try(:delete, :options) || {}
          @service = service_class.new(params_hash, options)
        end

        def permitted_params
          raise "not implemented"
        end
      end

      module Service
        extend ActiveSupport::Concern

        def service_class
          self.class.service_class
        end
      end

      module Serialization
        private

        def serialize_result(result)
          result.as_json
        end

        def serialize_errors(errors)
          errors
        end
      end

      include RestActions
      include Service
      include Serialization
      include ApiControllerConcerns::ExceptionHandling
    end
  end
end
