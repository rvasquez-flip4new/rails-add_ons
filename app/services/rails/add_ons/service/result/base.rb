module Rails
  module AddOns
    module Service::Result
      class Base
        attr_reader :messages, :errors

        module Succeedable
          def success?
            !failed?
          end

          def failed?
            @errors.any?
          end

          def ok?
            success?
          end
        end

        include Succeedable
      end
    end
  end
end
