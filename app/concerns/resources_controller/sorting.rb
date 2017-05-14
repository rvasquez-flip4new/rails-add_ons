module ResourcesController::Sorting
  private

  def load_collection_scope
    add_order_scope(super)
  end

  def add_order_scope(base_scope)
    if params[:sort_by].present?
      base_scope.order(params[:sort_by] => (params[:sort_direction] || :asc))
    else
      base_scope
    end
  end
end