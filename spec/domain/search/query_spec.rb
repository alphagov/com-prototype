RSpec.describe Search::Query do
  describe "per_page" do
    it "defaults to 25" do
      expect(subject.per_page).to eq(25)
    end

    it "coerces strings to integers" do
      subject.per_page = "3"
      expect(subject.per_page).to eq(3)
    end

    it "limits to 100" do
      subject.per_page = 101
      expect(subject.per_page).to eq(100)
    end
  end

  describe "page" do
    it "defaults to 1" do
      expect(subject.page).to eq(1)
    end

    it "coerces strings to integers" do
      subject.page = "3"
      expect(subject.page).to eq(3)
    end

    it "sets to 1 if <= 0" do
      subject.page = 0
      expect(subject.page).to eq(1)

      subject.page = -123
      expect(subject.page).to eq(1)
    end
  end

  describe "sort" do
    it "defaults to page_views_desc" do
      expect(subject.sort.identifier).to eq(:six_months_page_views_desc)
    end
  end

  it "does not apply any filters by default" do
    expect(subject.filters).to be_empty
  end

  describe "audit_status" do
    it "adds a filter" do
      subject.audit_status = :audited
      expect(subject.filters).to be_present
    end
  end

  describe "theme" do
    it "does not add a filter if an unrecognised type" do
      subject.theme = "Unknown_123"
      expect(subject.filters).to be_empty
    end

    context "when filtering by theme" do
      let(:theme) { create(:theme) }
      let(:identifier) { "Theme_#{theme.id}" }

      it "adds a rules filter when setting the theme" do
        subject.theme = identifier

        expect(subject.filters).to be_present
        expect(subject.filters.first).to be_a(Search::RulesFilter)
      end

      it "raises an error if theme doesn't exist" do
        expect { subject.theme = "Theme_999" }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when filtering by subtheme" do
      let(:subtheme) { create(:subtheme) }
      let(:identifier) { "Subtheme_#{subtheme.id}" }

      it "adds a rules filter when setting the theme" do
        subject.theme = identifier

        expect(subject.filters).to be_present
        expect(subject.filters.first).to be_a(Search::RulesFilter)
      end

      it "raises an error if subtheme doesn't exist" do
        expect { subject.theme = "Subtheme_999" }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "document_type" do
    it "adds a filter" do
      subject.document_type = "organisation"
      expect(subject.filters).to be_present
    end
  end

  describe "#filter_by" do
    it "raises an error if a filter already exists for a type" do
      subject.filter_by("organisations", nil, "org1")

      expect { subject.filter_by("organisations", nil, "org1") }
        .to raise_error(FilterError, /duplicate/)
    end

    it "raises an error if filtering by both source and target" do
      subject.filter_by("organisations", nil, "org1")

      expect { subject.filter_by("policies", "id2", nil) }
        .to raise_error(FilterError, /source and target/)
    end

    it "raises errors correctly when other types of filters are set" do
      subject.audit_status = :audited
      subject.filter_by("organisations", nil, "org1")

      expect { subject.filter_by("policies", "id2", nil) }
        .to raise_error(FilterError, /source and target/)
    end

    it "stores the list of filters" do
      subject.filter_by("organisations", nil, "org1")
      subject.filter_by("policies", nil, "org2")

      expect(subject.filters.count).to eq(2)
    end
  end
end
