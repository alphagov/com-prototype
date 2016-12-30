require 'rails_helper'

RSpec.describe Importers::ContentItemsByOrganisation do
  describe '#run' do
    let!(:organisation) { create(:organisation, slug: 'the-slug') }

    context 'when the content item does not exist' do
      it 'creates a content item per attribute group from collector' do
        attrs1 = FactoryGirl.attributes_for(:content_item)
        attrs2 = FactoryGirl.attributes_for(:content_item)
        allow_any_instance_of(ContentItemsService).to receive(:find_each).with('the-slug').and_yield(attrs1).and_yield(attrs2)

        expect { subject.run('the-slug') }.to change { ContentItem.count }.by(2)
      end

      it 'assign the new attributes' do
        attrs1 = FactoryGirl.attributes_for(:content_item, link: 'the-link-value', title: 'the-title')
        allow_any_instance_of(ContentItemsService).to receive(:find_each).and_yield(attrs1)
        subject.run('the-slug')

        attributes = ContentItem.find_by(link: 'the-link-value').attributes.symbolize_keys
        expect(attributes).to include(title: 'the-title')
      end
    end

    context 'when a the content item already exist' do
      let(:content_item) { create(:content_item, link: 'the-link', organisation: organisation) }

      it 'does not create a new one' do
        attributes = { content_id: content_item.content_id, link: 'the-link' }
        allow_any_instance_of(ContentItemsService).to receive(:find_each).and_yield(attributes)

        expect { subject.run('the-slug') }.to change { ContentItem.count }.by(0)
      end

      it 'update the attributes' do
        content_item.update(title: 'old-title')
        attributes = { content_id: content_item.content_id, title: 'the-new-title' }
        allow_any_instance_of(ContentItemsService).to receive(:find_each).and_yield(attributes)

        subject.run('the-slug')

        expect(ContentItem.first.title).to eq('the-new-title')
      end
    end
  end
end
