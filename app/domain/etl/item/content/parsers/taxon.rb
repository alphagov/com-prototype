class Etl::Item::Content::Parsers::Taxon
  def parse(json)
    html = []
    html << json.dig("description")
    children = json.dig("links", "child_taxons")
    unless children.nil?
      children.each do |child|
        html << child["title"]
        html << child["description"]
      end
    end
    html.join(" ")
  end

  def schemas
    %w[taxon]
  end
end
