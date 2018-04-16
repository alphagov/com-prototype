class Content::Parsers::Formats::Need
  def parse(json)
    html = []
    html << json.dig('details', 'role')
    html << json.dig('details', 'goal')
    html << json.dig('details', 'benefit')
    html.join(' ')
  end

  def schemas
    ['need']
  end
end
