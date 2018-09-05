class Etl::Item::Content::Parsers::StatisticsAnnouncement
  def parse(json)
    html = []
    html << json.dig("description")
    html << json.dig("details", "display_date")
    html << json.dig("details", "state")
    html.join(" ")
  end

  def schemas
    %w[statistics_announcement]
  end
end
