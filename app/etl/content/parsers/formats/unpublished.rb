class Content::Parsers::Formats::Unpublished
  def parse(json)
    json.dig("details", "explanation")
  end

  def schemas
    %w[unpublishing gone]
  end
end
