module ContentItemsHelper
  def advanced_filter_enabled?
    params[:taxons].present?
  end
end
