require 'rails_helper'

RSpec.describe 'content_items/show.html.erb', type: :view do
  let(:content_item) { build(:content_item) }

  it 'renders the title of the content item' do
    content_item.title = 'A Title'
    assign(:content_item, content_item)
    render

    expect(rendered).to have_selector('h1', text: 'A Title')
  end

  it 'renders the url of the content item' do
    content_item.link = '/content/1/path'
    assign(:content_item, content_item)
    render

    expect(rendered).to have_text('Page on GOV.UK')
    expect(rendered).to have_link('https://gov.uk/content/1/path', href: 'https://gov.uk/content/1/path')
  end

  it 'renders the document type of the content item' do
    content_item.document_type = 'guidance'
    assign(:content_item, content_item)
    render

    expect(rendered).to have_text('Document type')
    expect(rendered).to have_text('guidance')
  end

  it 'renders the last updated date of the content item' do
    Timecop.freeze('2016-3-20')
    assign(:content_item, content_item)
    content_item.public_updated_at = Date.parse('2016-1-20')
    render

    expect(rendered).to have_text('Last updated')
    expect(rendered).to have_text('2 months ago')
  end

  it 'renders the description of the content item' do
    content_item.description = 'The description of a content item'
    assign(:content_item, content_item)
    render

    expect(rendered).to have_text('Description')
    expect(rendered).to have_text('The description of a content item')
  end
end
