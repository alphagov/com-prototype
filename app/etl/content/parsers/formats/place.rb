class Content::Parsers::Formats::Place
  def parse(json)
    html = []
    html << json.dig("details", "introduction")
    html << json.dig("details", "more_information")
    html.join(" ")
  end

  def schemas
    ['place']
  end
end
