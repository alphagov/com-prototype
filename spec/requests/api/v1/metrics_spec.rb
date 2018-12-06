require 'securerandom'

RSpec.describe '/api/v1/metrics/', type: :request do
  before { create(:user) }

  let!(:day1) { Date.new(2018, 1, 13) }
  let!(:day2) { Date.new(2018, 1, 14) }
  let!(:day3) { Date.new(2018, 1, 15) }
  let!(:day4) { Date.new(2018, 1, 16) }
  let!(:content_id) { SecureRandom.uuid }
  let!(:base_path) { '/base_path' }

  let!(:edition) do
    create :edition,
      content_id: content_id,
      title: 'the title',
      date: day1,
      base_path: base_path,
      document_type: 'guide',
      locale: 'en',
      publishing_app: 'whitehall',
      first_published_at: '2018-02-01',
      public_updated_at: '2018-04-25',
      primary_organisation_title: 'The ministry'
  end
  let!(:edition_fr) { create :edition, content_id: content_id, locale: 'de' }

  include_examples 'API response', '/api/v1/metrics'

  describe 'Daily metrics' do
    context 'succcessful response' do
      before do
        create :metric, edition: edition, date: day1, pviews: 10, feedex: 10, useful_yes: 10, useful_no: 30
        create :metric, edition: edition_fr, date: day2, pviews: 100, feedex: 200, useful_yes: 10, useful_no: 30
        create :metric, edition: edition, date: day2, pviews: 20, feedex: 20, useful_yes: 10, useful_no: 30
        create :metric, edition: edition, date: day3, pviews: 30, feedex: 30, useful_yes: 10, useful_no: 30
        create :metric, edition: edition, date: day4, pviews: 40, feedex: 40, useful_yes: 10, useful_no: 30
      end

      describe "Summary information" do
        it 'returns the sum of feedex comments' do
          get "//api/v1/metrics/#{base_path}", params: { from: '2018-01-13', to: '2018-01-15', metrics: %w[feedex] }


          json = JSON.parse(response.body)

          expect(json.deep_symbolize_keys).to include(
            feedex: 60
          )
        end
      end

      def build_time_series_response(metric_name)
        {
          metric_name.to_sym => [
            { date: '2018-01-13', value: 10 },
            { date: '2018-01-14', value: 20 },
            { date: '2018-01-15', value: 30 },
          ]
        }
      end
    end

    it 'returns the metadata from the latest edition' do
      get "//api/v1/metrics/#{base_path}", params: { from: '2018-01-13', to: '2018-01-15', metrics: %w[feedex] }

      json = JSON.parse(response.body)

      expect(json.deep_symbolize_keys).to include(
        title: 'the title',
        base_path: base_path,
        document_type: 'guide',
        publishing_app: 'whitehall',
        first_published_at: '2018-02-01T00:00:00.000Z',
        public_updated_at: '2018-04-25T00:00:00.000Z',
        primary_organisation_title: 'The ministry'
      )
    end

    context 'when the base path does not exist' do
      it 'returns a 404 response' do
        get '/api/v1/metrics/non/existant/base/path',
        params: { from: '2018-01-01', to: '2018-06-01', metrics: %w[pviews] }
        expect(response.status).to eq(404)

        json = JSON.parse(response.body)

        expected_error_response = {
          "type" => "https://content-performance-api.publishing.service.gov.uk/errors.html#base-path-not-found",
          "title" => "The base path you are looking for cannot be found",
          "invalid_params" => %w[base_path]
        }

        expect(json).to eq(expected_error_response)
      end
    end
  end

  describe "metrics index" do
    it "describes the available metrics" do
      get "/api/v1/metrics"

      json = JSON.parse(response.body)

      expect(json.count).to eq(::Metric.find_all.length)

      expect(json).to include("name" => "pviews",
        "description" => "Number of pageviews",
        "source" => "Google Analytics")
    end
  end
end
