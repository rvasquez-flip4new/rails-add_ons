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
              scope = scope.limit(condition.to_i)
            when 'offset'
              scope = scope.offset(condition.to_i)
            when 'order'
              scope = scope.order(condition)
            when 'includes'
              scope = scope.includes(condition.map(&:to_sym))
            else
              condition_statement = ::Api::ResourcesController::ConditionParser.new(field, condition).condition_statement
              scope = scope.where(condition_statement)
            end
          end
          scope
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
          if respond_to?(:before_action)
            before_action :load_count, only: [:count]
          else
            before_filter :load_count, only: [:count]
          end
        end

        def count
          respond_to do |format|
            format.json { render json: { count: @count } }
          end
        end

        private

        def load_count
          base_scope = resource_class
          scope = add_conditions_from_query(base_scope)
          @count = scope.count
        end
      end

      module DestroyAllAction
        extend ActiveSupport::Concern

        included do
          if respond_to?(:before_action)
            before_action :load_and_destroy_collection, only: [:destroy_all]
          else
            before_filter :load_and_destroy_collection, only: [:destroy_all]
          end
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

      module DeleteAllAction
        extend ActiveSupport::Concern

        included do
          if respond_to?(:before_action)
            before_action :delete_collection, only: [:delete_all]
          else
            before_filter :delete_collection, only: [:delete_all]
          end
        end

        def delete_all
          respond_to do |format|
            format.json { render json: { count: @count } }
          end
        end

        private

        def delete_collection
          @count = resource_class.delete_all
        end
      end

      module FirstAction
        extend ActiveSupport::Concern

        included do
          if respond_to?(:before_action)
            before_action :load_first, only: [:first]
          else
            before_filter :load_first, only: [:first]
          end
        end

        def first
          respond_to do |format|
            if @resource.nil?
              format.json { render json: nil }
            else
              format.json { render json: [serialize_resource(@resource)] }
            end
          end
        end

        private

        def load_first
          base_scope = resource_class
          scope = add_conditions_from_query(base_scope)
          @resource = scope.first
        end
      end

      module LastAction
        extend ActiveSupport::Concern

        included do
          if respond_to?(:before_action)
            before_action :load_last, only: [:last]
          else
            before_filter :load_last, only: [:last]
          end
        end

        def last
          respond_to do |format|
            if @resource.nil?
              format.json { render json: nil }
            else
              format.json { render json: [serialize_resource(@resource)] }
            end
          end
        end

        private

        def load_last
          base_scope = resource_class
          scope = add_conditions_from_query(base_scope)
          @resource = scope.last
        end
      end

      include RestActions
      include Resources
      include RestResourceUrls
      include Serialization
      include CountAction
      include DestroyAllAction
      include DeleteAllAction
      include FirstAction
      include LastAction
      include ApiControllerConcerns::ExceptionHandling

      if ActionController.const_defined?('Parameters')
        class PatchedParameters < ActionController::Parameters
          def require key
            begin
              super key
            rescue ActionController::ParameterMissing => e
              if self[key].nil? || self[key].empty?
                return PatchedParameters.new
              else
                raise e
              end
            end
          end
        end

        def params
          @_params ||= PatchedParameters.new(request.parameters)
        end
      end
    end
  end
end
