RSpec.describe Content::Query do
  describe "with some content tagged to organisations and policies" do
    let!(:organisation_1) { create(:organisation) }
    let!(:organisation_2) { create(:organisation) }
    let!(:policy_1) { create(:policy) }

    let!(:content_item_1) do
      create(
        :content_item,
        organisations: organisation_1,
      )
    end

    let!(:content_item_2) do
      create(
        :content_item,
        organisations: organisation_2,
        policies: policy_1,
      )
    end

    let!(:content_item_3) do
      create(
        :content_item,
        organisations: organisation_1,
        policies: policy_1,
      )
    end

    it "can paginate" do
      subject
        .per_page(5)
        .page(2)

      expect(subject.content_items).to have_attributes(total_pages: 2, count: 1)
    end

    it "can filter by a single organisation" do
      subject.organisations(organisation_1.content_id)
      expect(subject.content_items).to contain_exactly(content_item_1, content_item_3)
    end

    it "can filter by multiple organisations" do
      subject.organisations([organisation_1, organisation_2].map(&:content_id))
      expect(subject.content_items).to contain_exactly(content_item_1, content_item_2, content_item_3)
    end

    it "can filter by both organisation and policy" do
      subject
        .organisations(organisation_1.content_id)
        .policies(policy_1.content_id)

      expect(subject.content_items).to contain_exactly(content_item_3)
    end

    it "can filter by multiple organisations and a policy" do
      subject
        .organisations([organisation_1, organisation_2].map(&:content_id))
        .policies(policy_1.content_id)

      expect(subject.content_items).to contain_exactly(content_item_2, content_item_3)
    end

    it "returns no results if there is no target for the type" do
      subject.organisations(policy_1.content_id)
      expect(subject.content_items).to be_empty
    end

    it "can filter by document type" do
      travel_advice = create(:content_item, document_type: "travel_advice")
      subject.document_type("travel_advice")
      expect(subject.content_items).to contain_exactly(travel_advice)
    end

    it "can return an unpaginated scope of content items" do
      subject.per_page(2)

      expect(subject.content_items.size).to eq(2)
      expect(subject.all_content_items.size).to eq(6)
    end

    it "can filter by title" do
      foo = create(:content_item, title: "barfoobaz")
      subject.title("foo")
      expect(subject.content_items).to contain_exactly(foo)
    end
  end

  describe "with 26 content items" do
    let!(:content_items) { create_list(:content_item, 26) }

    it "defaults to the page 1 with 25 per page" do
      expect(subject.content_items.count).to eq 25
      expect(subject.content_items).to match_array(content_items[0..24])
    end

    describe "theme" do
      before do
        subject.per_page(100)
        expect(subject.content_items.count).to eq 26
      end

      it "does not add a filter if it is an unrecognised type" do
        subject.theme("Unknown_123")
        expect(subject.content_items.count).to eq 26
      end

      describe "when filtering by theme" do
        let(:theme) { create(:theme) }
        let(:identifier) { "Theme_#{theme.id}" }

        it "adds a rules filter when setting the theme" do
          subject.theme(identifier)
          expect(subject.content_items).to be_empty
        end

        it "raises an error if theme doesn't exist" do
          expect { subject.theme("Theme_999") }
            .to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      describe "when filtering by subtheme" do
        let(:subtheme) { create(:subtheme) }
        let(:identifier) { "Subtheme_#{subtheme.id}" }

        it "adds a rules filter when setting the theme" do
          subject.theme(identifier)
          expect(subject.content_items).to be_empty
        end

        it "raises an error if subtheme doesn't exist" do
          expect { subject.theme("Subtheme_999") }
            .to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  describe "with content items with page views" do
    let!(:content_item_1) { create(:content_item, six_months_page_views: 3) }
    let!(:content_item_2) { create(:content_item, six_months_page_views: 3) }
    let!(:content_item_3) { create(:content_item, six_months_page_views: 1) }
    let!(:content_item_4) { create(:content_item, six_months_page_views: 9) }

    it "defaults to six month page views descending" do
      expect(subject.content_items.pluck(:six_months_page_views)).to match_array [9, 3, 3, 1]
    end
  end
end
