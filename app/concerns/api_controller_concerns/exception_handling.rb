module ApiControllerConcerns
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
end
