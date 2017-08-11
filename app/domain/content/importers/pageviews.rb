module Content
  class Importers::Pageviews
    def self.run(*args)
      new.run(*args)
    end

    def initialize
      @google_analytics_service = GoogleAnalyticsService.new
    end

    def run(content_items)
      base_paths = content_items.pluck(:base_path)

      results = @google_analytics_service.page_views(base_paths)
      results.each do |result|
        content_item = Item.find_by(base_path: result[:base_path])
        content_item.update!(result.slice(:one_month_page_views, :six_months_page_views))
      end
    end
  end
end
