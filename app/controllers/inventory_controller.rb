class InventoryController < ApplicationController
  helper_method :set_param, :rule_exists?, :selection_params

  before_action(
    :require_inventory_management_permission!,
    :assign_link_types,
    :lookup_theme,
    :lookup_subtheme,
    :lookup_link_type,
    :lookup_or_build_rule,
    :build_theme,
    :build_subtheme,
    :assign_content_items,
  )

  def show
  end

  def add_theme
    theme = Theme.create!(theme_params)
    rerender(theme_id: theme.id)
  end

  def add_subtheme
    subtheme = Subtheme.create!(subtheme_params)
    rerender(subtheme_id: subtheme.id)
  end

  def toggle
    message = toggle_rule
    request.xhr? ? render(plain: message) : rerender
  end

private

  def require_inventory_management_permission!
    authorise_user!("inventory_management")
  end

  def assign_link_types
    @link_types = Search::GROUPABLE_LINK_TYPES
  end

  def assign_content_items
    search = Search.new

    @content_items = search
      .options_for(@link_type)
      .order(:title)
  end

  def lookup_link_type
    @link_type = params[:link_type].presence
    @link_type ||= @link_types.first
  end

  def lookup_theme
    @theme = Theme.find(params[:theme_id]) if params[:theme_id].present?
    @theme ||= Theme.first
  end

  def lookup_subtheme
    @subtheme = Subtheme.find(params[:subtheme_id]) if params[:subtheme_id].present?
    @subtheme = @theme.subthemes.first if @theme && (!@subtheme || @subtheme.theme != @theme)
  end

  def build_theme
    @new_theme = Theme.new
  end

  def build_subtheme
    @new_subtheme = Subtheme.new
  end

  def set_param(key, value)
    url_for(request.query_parameters.merge(key => value))
  end

  def rule_exists?(content_item)
    return false unless @subtheme

    @rules ||= @subtheme.inventory_rules.where(link_type: @link_type)
    @rules.any? { |r| r.target_content_id == content_item.content_id }
  end

  def lookup_or_build_rule
    return if params[:content_id].blank?

    @rule = InventoryRule.find_or_initialize_by(
      subtheme: @subtheme,
      link_type: @link_type,
      target_content_id: params.fetch(:content_id),
    )
  end

  def toggle_rule
    if @rule.new_record?
      @rule.save!
      "created"
    else
      @rule.destroy
      "destroyed"
    end
  end

  def rerender(params = {})
    redirect_to selection_params.merge(params.merge(action: :show))
  end

  def selection_params
    request
      .query_parameters
      .deep_symbolize_keys
  end

  def theme_params
    params.require(:theme).permit(:name)
  end

  def subtheme_params
    params.require(:subtheme).permit(:name, :theme_id)
  end
end
