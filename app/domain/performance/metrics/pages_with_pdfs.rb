module Performance::Metrics
  class PagesWithPdfs
    attr_accessor :content_items

    def initialize(content_items)
      @content_items = content_items
    end

    def run
      percentage = 0
      total = content_items.where("number_of_pdfs > ?", 0).count

      percentage = (total.to_f / content_items.count.to_f) * 100 if total.positive?

      {
        pages_with_pdfs: {
          value: total,
          percentage: percentage
        }
      }
    end
  end
end
