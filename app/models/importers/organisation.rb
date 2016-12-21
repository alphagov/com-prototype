class Importers::Organisation
  attr_reader :slug, :batch, :start
  attr_writer :start

  def initialize(slug, batch: 10, start: 0)
    @slug = slug
    @batch = batch
    @start = start
  end

  def run
    @organisation = ::Organisation.find_or_create_by(slug: slug)

    loop do
      result = search_content_items_for_organisation

      organisation_titles = get_organisation_titles(result)

      if organisation_titles.any? && organisation_titles.first && @organisation.title.blank?
        add_organisation_title(organisation_titles.first)
      end

      result.each do |content_item_attributes|
        content_id = content_item_attributes['content_id']
        link = content_item_attributes['link']

        if content_id.present?
          content_store_item = content_item_store(link)

          attributes = content_item_attributes.slice(*CONTENT_ITEM_FIELDS)
            .merge(content_store_item.slice(*CONTENT_STORE_FIELDS))

          create_or_update_content_item(content_id, attributes)
        else
          log("There is not content_id for #{slug}")
        end
      end

      break if last_page?(result)

      next_page!
    end
    raise 'No result for slug' if @organisation.content_items.empty?
  end

  def add_organisation_title(title)
    @organisation.update!(title: title)
  end

private

  CONTENT_ITEM_FIELDS = %w(content_id description link title).freeze
  CONTENT_STORE_FIELDS = %w(public_updated_at document_type).freeze
  SEARCH_API_FIELDS = CONTENT_ITEM_FIELDS + %w(organisations)

  private_constant :CONTENT_ITEM_FIELDS, :SEARCH_API_FIELDS

  def last_page?(results)
    results.length < batch
  end

  def next_page!
    self.start += batch
  end

  def search_content_items_for_organisation
    response = HTTParty.get(search_api_end_point)
    JSON.parse(response.body).fetch('results')
  end

  def search_api_end_point
    "https://www.gov.uk/api/search.json?filter_organisations=#{slug}&count=#{batch}&fields=#{SEARCH_API_FIELDS.join(',')}&start=#{start}"
  end

  def content_item_store(base_path)
    endpoint = content_item_end_point(base_path)
    response = HTTParty.get(endpoint)
    JSON.parse(response.body)
  end

  def content_item_end_point(base_path)
    "https://www.gov.uk/api/content#{base_path}"
  end

  def log(message)
    unless Rails.env.test?
      Logger.new(STDOUT).warn(message)
    end
  end

  def get_organisation_titles(content_items)
    titles = content_items.map do |content_item|
      organisations = content_item['organisations'].first
      organisations['title'] if organisations.present?
    end
    titles
  end

  def create_or_update_content_item(content_id, attributes)
    content_item = @organisation.content_items.find_by(content_id: content_id)

    if content_item.blank?
      create_content_item(attributes)
    else
      update_content_item(content_item, attributes)
    end
  end

  def create_content_item(attributes)
    @organisation.content_items << ContentItem.new(attributes)
  end

  def update_content_item(content_item, attributes)
    content_item.update!(attributes)
  end
end
