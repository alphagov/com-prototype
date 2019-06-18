class Streams::Handlers::BaseHandler
  def update_editions(items_with_old_editions)
    publishing_api_event = Events::PublishingApi.new(payload: @payload, routing_key: @routing_key)
    items_to_grow = items_with_old_editions.select do |item|
      Streams::GrowDimension.should_grow? old_edition: item[:old_edition], attrs: item[:attrs]
    end
    items_to_grow.map do |item|
      update_edition(item[:attrs], item[:old_edition], publishing_api_event)
    end
  end

private

  def update_edition(new_edition_attr, old_edition, publishing_api_event)
    attributes = new_edition_attr.merge(publishing_api_event: publishing_api_event)
    new_edition = Dimensions::Edition.new(attributes)
    new_edition.facts_edition = Etl::Edition::Processor.process(old_edition, new_edition)
    new_edition.promote!(old_edition)
    new_edition
  end
end
