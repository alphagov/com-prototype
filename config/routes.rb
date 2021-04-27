Rails.application.routes.draw do
  root to: "items#index"

  resources :items, only: %w[index show], param: :content_id

  namespace :api, defaults: { format: :json } do
    get "/v1/metrics/", to: "metrics#index"
    get "/v1/healthcheck", to: "healthcheck#index"
    get "/v1/organisations", to: "organisations#index"
    get "/v1/document_types", to: "document_types#index"
    get "/v1/documents/:document_id/children", to: "documents#children"
  end

  get "/content", to: "content#show", defaults: { format: :json }
  get "/single_page/(*base_path)", to: "single_item#show", defaults: { format: :json }, format: false
  get "/healthcheck/metrics",
      to: GovukHealthcheck.rack_response(
        Healthchecks::DailyMetricsCheck,
        Healthchecks::EtlMetricValues.build(:pviews),
        Healthchecks::EtlMetricValues.build(:upviews),
        Healthchecks::EtlMetricValues.build(:searches),
        Healthchecks::EtlMetricValues.build(:feedex),
      )
  get "/healthcheck/search",
      to: GovukHealthcheck.rack_response(
        Healthchecks::MonthlyAggregations,
        Healthchecks::SearchAggregations.build(:last_month),
        Healthchecks::SearchAggregations.build(:last_six_months),
        Healthchecks::SearchAggregations.build(:last_thirty_days),
        Healthchecks::SearchAggregations.build(:last_three_months),
        Healthchecks::SearchAggregations.build(:last_twelve_months),
      )

  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::ActiveRecord,
    GovukHealthcheck::SidekiqRedis,
  )
end
