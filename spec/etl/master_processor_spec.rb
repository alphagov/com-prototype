require 'rails_helper'
require 'gds-api-adapters'

RSpec.describe MasterProcessor do
  subject { described_class }

  let(:date) { Date.new(2018, 2, 20) }

  around do |example|
    Timecop.freeze(date) { example.run }
  end

  before do
    allow(GA::Processor).to receive(:process)
    allow(Feedex::Processor).to receive(:process)
    allow(Content::OutdatedItems::Processor).to receive(:process)
    allow(Content::Metrics::Processor).to receive(:process)
  end

  it 'does not process if already processed for date' do
    create(:dimensions_date, date: Date.yesterday)

    expect { subject.process }.to raise_error(MasterProcessor::DuplicateDateError)
  end

  it 'creates a Metrics fact per content item' do
    subject.process
    expect(Content::Metrics::Processor).to have_received(:process).with(date: Date.new(2018, 2, 19))
  end

  it 'updates the outdated items' do
    subject.process

    expect(Content::OutdatedItems::Processor).to have_received(:process).with(date: Date.new(2018, 2, 19))
  end

  it 'update GA metrics in the Facts table' do
    expect(GA::Processor).to receive(:process).with(date: Date.new(2018, 2, 19))

    subject.process
  end

  it 'update Feedex metrics in the Facts table' do
    expect(Feedex::Processor).to receive(:process).with(date: Date.new(2018, 2, 19))

    subject.process
  end

  it 'can run the process for other days' do
    another_date = Date.new(2017, 12, 30)
    subject.process(date: another_date)
    expect(Content::Metrics::Processor).to have_received(:process).with(date: another_date)
    expect(Content::OutdatedItems::Processor).to have_received(:process).with(date: another_date)
    expect(GA::Processor).to have_received(:process).with(date: another_date)
    expect(Feedex::Processor).to have_received(:process).with(date: another_date)
  end
end
