class ContentItemsController < ApplicationController
  def index
    @organisation = Organisation.find(params[:organisation_id])
    @content_items = @organisation.content_items.order("#{params[:sort]} #{params[:order]}").page(params[:page])
  end

  def show
    head :ok
  end
end
