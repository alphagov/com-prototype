Rails.application.routes.draw do
  root to: 'content_items#index'

  resources :groups, only: %w(show create index destroy), param: "slug"

  resources :content_items, only: %w(index show) do
    get :audit, to: "audits#show"
    post :audit, to: "audits#save"
    patch :audit, to: "audits#save"
    get "audit/next", to: "audits#next"
  end

  resources :audits, only: %w(index guidance)

  namespace :audits do
    get :report
    get :export
    get :guidance
  end

  get "audit-guidance", to: "audits#guidance"

  namespace :inventory do
    root action: "show"
    get :toggle, action: "toggle"
    post :themes, action: "add_theme"
    post :subthemes, action: "add_subtheme"
  end

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end
end
