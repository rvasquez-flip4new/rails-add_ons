module Rails
  module AddOns
    module Service
      class Base
        include ActiveModel::Model
        extend ActiveModel::Naming

        def self.attr_accessor(*args)
          super
          add_attribute_names(*args)
        end

        def self.add_attribute_names(*args)
          args.each do |attr_name|
            attribute_names << attr_name
          end
        end

        def self.attribute_names
          (@attr_names ||= [])
        end

        def self.call(*args)
          new(*args).perform
        end

        def initialize(attributes = {}, options = {}, &block)
          @options    = options
          @block      = block
          @attributes = {}
          set_attributes(attributes)
          initialize_result
          initialize_errors
          initialize_messages
          after_initialize
        end

        private

        module Attributes
          def set_attributes(attributes)
            attributes.each do |key, value|
              send("#{key}=", value)
            end
          end
        end

        include Attributes

        module Callbacks
          def after_initialize; end
          def before_perform; end
          def after_perform; end
          def before_validation; end
          def after_validation; end
          def after_perform; end

          def perform
            before_validation
            return perform_result unless valid?
            after_validation
            before_perform
            say "Performing" do
              _perform
            end
            after_perform
            perform_result
          end
        end

        module Resultable
          private

          def initialize_result
            @result = result_class.new
          end

          def perform_result
            copy_messages_to_result
            copy_errors_to_result
            @result
          end

          def result_class
            "#{self.class.name}::Result".constantize
          end
        end

        module Errors
          private

          def initialize_errors
            @errors = ActiveModel::Errors.new(self)
          end

          def copy_errors_to_result
            @result.instance_variable_set(:@errors, @errors)
          end

          def copy_errors_from_to(obj, key_prefix)
            obj.errors.each do |key, message|
              @errors.add(key_prefix, message)
            end
          end
        end

        module Messages
          private

          def initialize_messages
            @messages = []
          end

          def say(what, &block)
            @indent ||= 0
            if block_given?
              @indent += 1
              output "#{output_prefix}#{("  " * @indent)}#{what}..."
              block_result = yield
              say_done
              @indent -= 1
              block_result
            else
              output "#{output_prefix}#{("  " * @indent)}#{what}"
            end
          end

          def say_done
            say "  => Done"
          end

          def output_prefix
            "[#{self.class.name}] "
          end

          def output(what)
            @messages << what
            puts what
          end

          def copy_messages_to_result
            @result.instance_variable_set(:@messages, @messages)
          end
        end

        include Errors
        include Resultable
        include Callbacks
        include Messages
      end
    end
  end
end
