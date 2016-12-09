require 'rails_helper'

RSpec.describe 'content_items/index.html.erb', type: :view do
  let(:organisation) { build(:organisation) }
  let(:content_items) { build_list(:content_item, 2) }

  before do
    assign(:content_items, content_items)
    assign(:organisation, organisation)
  end

  it 'renders the name of the organisation from the slug' do
    allow(organisation).to receive(:name).and_return('A Name')
    render

    expect(rendered).to have_selector('h1', text: 'A Name')
  end

  it 'renders the table header with the right headings' do
    render

    expect(rendered).to have_selector('table thead', text: 'Title')
    expect(rendered).to have_selector('table thead tr:first-child th:nth(2)', text: 'Last Updated')
  end

  it 'renders a row per Content Item' do
    render

    expect(rendered).to have_selector('table tbody tr', count: 2)
  end

  describe 'row content' do
    it 'includes the content item title' do
      content_items[0].link = '/content/1/path'
      content_items[0].title = 'a-title'
      render

      expect(rendered).to have_link('a-title', href: 'https://gov.uk/content/1/path')
    end

    it 'includes the last time the content was updated' do
      Timecop.freeze(Time.parse('2016-3-20')) do
        content_items[0].public_updated_at = Time.parse('2016-1-20')
        render

        expect(rendered).to have_selector('table tbody tr td', text: '2 months ago')
      end
    end

    it 'contains a descending and ascending links in table heading' do
      render
      href = organisation_content_items_path(organisation, order: :asc, sort: :public_updated_at)

      expect(rendered).to have_link('Last Updated', href: href)
    end
  end
end
