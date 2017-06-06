module Rails
  module AddOns
    module Service
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
      end
    end
  end
