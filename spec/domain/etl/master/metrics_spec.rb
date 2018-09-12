RSpec.describe Etl::Master::MetricsProcessor do
  let(:date) { Date.new(2018, 3, 15) }

  subject { described_class.new(date: date) }

  it 'creates a Metrics fact per content item' do
    create :dimensions_item, latest: true
    item = create(:dimensions_item, latest: true, content_id: 'cid1')

    subject.process

    expect(Facts::Metric.count).to eq(2)
    expect(Facts::Metric.find_by(dimensions_item: item)).to have_attributes(
      dimensions_date: Dimensions::Date.find_or_create(Date.new(2018, 3, 15)),
      dimensions_item: item,
    )
  end

  it 'only create a Metrics Fact entry for Content Items with latest = `true`' do
    create(:dimensions_item, latest: true, content_id: 'cid1')
    create(:dimensions_item, latest: false, content_id: 'cid1')

    subject.process

    expect(Facts::Metric.count).to eq(1)
  end
end
