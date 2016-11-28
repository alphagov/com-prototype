require 'rails_helper'

RSpec.describe Importers::Organisation do
  let(:one_content_item_response) { build_seach_api_response [content_id: 'content-id-1'] }
  let(:two_content_items_response) { build_seach_api_response [{content_id: 'content-id-1'}, {content_id: 'content-id-2'}] }

  it 'queries the search API with the organisation\'s slug' do
    expected_url = 'https://www.gov.uk/api/search.json?filter_organisations=MY-SLUG&count=99&fields=content_id&start=0'
    expect(HTTParty).to receive(:get).with(expected_url).and_return(one_content_item_response)

    Importers::Organisation.run('MY-SLUG', batch: 99)
  end

  context 'Organisation' do
    it 'imports an organisation with the provided slug' do
      expect(HTTParty).to receive(:get).and_return(one_content_item_response)

      slug = 'hm-revenue-customs'
      Importers::Organisation.run(slug)

      expect(Organisation.count).to eq(1)
      expect(Organisation.first.slug).to eq(slug)
    end

    it 'raises an exception with an organisation that does not exist' do
      response = double(body: {results: []}.to_json)
      allow(HTTParty).to receive(:get).and_return(response)

      expect { Importers::Organisation.run('none-existing-org') }.to raise_error('No result for slug')
    end
  end

  context 'Content Items' do
    it 'imports all content items for the organisation' do
      allow(HTTParty).to receive(:get).and_return(two_content_items_response)
      Importers::Organisation.run('a-slug')
      organisation = Organisation.find_by(slug: 'a-slug')

      expect(organisation.content_items.count).to eq(2)
    end

    it 'imports a `content_id` for every content item' do
      allow(HTTParty).to receive(:get).and_return(two_content_items_response)
      Importers::Organisation.run('a-slug')
      organisation = Organisation.find_by(slug: 'a-slug')

      content_ids = organisation.content_items.pluck(:content_id)
      expect(content_ids).to eq(%w(content-id-1 content-id-2))
    end
  end

  context 'Pagination' do
    it 'paginates through all the content items for an organisation' do
      expect(HTTParty).to receive(:get).twice.and_return(two_content_items_response, one_content_item_response)
      Importers::Organisation.run('a-slug', batch: 2)
      organisation = Organisation.find_by(slug: 'a-slug')

      expect(organisation.content_items.count).to eq(3)
    end

    it 'handles last page with 0 results' do
      expect(HTTParty).to receive(:get).twice.and_return(one_content_item_response, build_seach_api_response([]))
      Importers::Organisation.run('a-slug', batch: 1)
      organisation = Organisation.find_by(slug: 'a-slug')

      expect(organisation.content_items.count).to eq(1)
    end
  end

  def build_seach_api_response(payload)
    double(body: {
      results: payload
    }.to_json)
  end

end
