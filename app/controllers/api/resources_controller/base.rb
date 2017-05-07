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
            before_action :load_resource_for_show, only: [:show]
            before_action :load_resource, only: [:update, :destroy, :delete]
            before_action :initialize_resource_for_create, only: [:create]
          else
            before_filter :load_collection, only: [:index]
            before_filter :load_collection, only: [:index]
            before_filter :load_resource_for_show, only: [:show]
            before_filter :load_resource, only: [:update, :destroy, :delete]
            before_filter :initialize_resource_for_create, only: [:create]
          end
        end

        def index
          respond_to do |format|
            format.json { render json: serialize_collection(@collection) }
          end
        end

        def show
          respond_to do |format|
            if @resource.nil?
              format.json { render json: { error: "Couldn't find #{resource_class} with ID=#{params[:id]}" }, status: :not_found }
            else
              format.json { render json: serialize_resource(@resource), status: :ok }
            end
          end
        end

        def create
          respond_to do |format|
            if @resource.save
              format.json { render json: serialize_resource(@resource), status: :created }
            else
              format.json { render json: { errors: serialize_errors(@resource.errors) }, status: 422 }
            end
          end
        end

        def update
          respond_to do |format|
            if @resource.update_attributes(permitted_params)
              format.json { render json: serialize_resource(@resource) }
            else
              format.json { render json: { errors: serialize_errors(@resource.errors) }, status: 422 }
            end
          end
        end

        def destroy
          @resource.destroy
          respond_to do |format|
            format.json { render json: serialize_resource(@resource) }
          end
        end

        def delete
          @resource.delete
          respond_to do |format|
            format.json { render json: serialize_resource(@resource) }
          end
        end

        private

        def load_collection
          base_scope = resource_class
          scope = add_conditions_from_query(base_scope)
          @collection = scope.all
        end

        def load_resource
          @resource = resource_class.find(params[:id])
        end

        def load_resource_for_show
          begin
            @resource = resource_class.find(params[:id])
          rescue ActiveRecord::RecordNotFound
            @resource = nil
          end
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

      module QueryConditions
        private

        def add_conditions_from_query(scope)
          request.query_parameters.each do |field, condition|
            case field
            when 'limit'
              scope = scope.limit(condition)
            when 'offset'
              scope = scope.offset(condition)
            when 'order'
              scope = scope.order(condition)
            else
              operator = extract_operator(condition.first[0])
              scope = scope.where("#{field} #{operator} ?", condition.first[1])
            end
          end
          scope
        end

        def extract_operator(operator)
          case operator
          when 'gt'
            ">"
          when 'gt_or_eq'
            ">="
          when 'eq'
            "is"
          when 'not_eq'
            "is not"
          when 'lt_or_eq'
            "<="
          when 'lt'
            "<"
          else
            raise "Unknown operator #{operator}"
          end
        end
      end

      include QueryConditions

      module Resources
        extend ActiveSupport::Concern

        def resource_class
          self.class.resource_class
        end
      end

      module RestResourceUrls
        extend ActiveSupport::Concern

        private

        def resource_url(resource)
          url_for(action: :show, id: resource.to_param)
        end
      end

      module Serialization
        private

        def serialize_collection(collection)
          collection.collect do |resource|
            json = resource.as_json
            json[:errors] = serialize_errors(resource.errors) if resource.errors.any?
            json
          end
        end

        def serialize_resource(resource)
          json = resource.as_json
          json[:errors] = serialize_errors(resource.errors) if resource.errors.any?
          json
        end

        def serialize_errors(errors)
          errors.as_json(full_messages: true)
        end
      end

      module CountAction
        extend ActiveSupport::Concern

        included do
          before_action :load_count, only: [:count]
        end

        def count
          respond_to do |format|
            format.json { render json: { count: @count } }
          end
        end

        private

        def load_count
          @count = resource_class.count
        end
      end

      module DestroyAllAction
        extend ActiveSupport::Concern

        included do
          before_action :load_and_destroy_collection, only: [:destroy_all]
        end

        def destroy_all
          respond_to do |format|
            format.json { render json: serialize_collection(@collection) }
          end
        end

        private

        def load_and_destroy_collection
          @collection = resource_class.destroy_all
        end
      end

      module ExceptionHandling
        extend ActiveSupport::Concern

        included do
          rescue_from Exception do |exception|
            if Rails.env.development? || Rails.env.test?
              error = { message: exception.message }

              error[:application_trace] = Rails.backtrace_cleaner.clean(exception.backtrace)
              error[:full_trace] = exception.backtrace 

              respond_to do |format|
                format.json { render json: error, status: 500 }
              end
            else
              respond_to do |format|
                format.json { render json: { error: 'Internal server error.' }, status: 500 }
              end
            end
          end
        end
      end

      include RestActions
      include Resources
      include RestResourceUrls
      include Serialization
      include CountAction
      include DestroyAllAction
      include ExceptionHandling
    end
  end
end
