class Content::Parsers::Parts
  def parse(json)
    html = []
    json.dig("details", "parts").each do |part|
      html << part["title"]
      html << part["body"]
    end
    html.join(" ")
  end
end
%w[guide travel_advise].each do |schema|
  Content::Parser.register(schema, Content::Parsers::Parts.new)
end