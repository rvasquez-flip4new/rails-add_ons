module ResourcesController::Pagination
  extend ActiveSupport::Concern

  included do
    helper_method :paginate?
  end

  def paginate?
    true
  end

  private

  def load_collection
    @collection = resource_class.page params[:page]
  end
end