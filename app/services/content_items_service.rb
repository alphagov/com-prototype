class ContentItemsService
  def find_each(organisation_slug)
    raise 'missing block!' unless block_given?

    query_params = { filter_organisations: organisation_slug }
    fields = %w(link)

    Clients::SearchAPI.find_each(query_params, fields) do |attributes|
      link = attributes.fetch(:link)
      content_item_attributes = %i(content_id title public_updated_at document_type link)

      yield Clients::ContentStore.find(link, content_item_attributes)
    end
  end
end
