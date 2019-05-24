require 'govuk_message_queue_consumer/test_helpers'

RSpec.describe Streams::Consumer do
  subject { described_class.new }

  it_behaves_like 'a message queue processor'

  context 'with valid payload' do
    let(:message) { build(:message) }

    it 'acknowledges the message' do
      subject.process(message)
      expect(message).to be_acked
    end

    it 'increments routing_key in statsd' do
      expect(GovukStatsd).to receive(:increment).with("monitor.messages.ack.successfully_processed")
      subject.process(message)
    end

    context 'and message is redelivered' do
      let(:message) { build(:message, redelivered?: true) }

      it 'acknowledges the message' do
        subject.process(message)
        expect(message).to be_acked
      end

      it 'increments `acknowledged` in statsd' do
        expect(GovukStatsd).to receive(:increment).with("monitor.messages.ack.successfully_processed")
        subject.process(message)
      end
    end
  end

  context 'with invalid payload' do
    let(:message) { build(:message, schema_name: 'placeholder') }

    it 'discards the message' do
      subject.process(message)
      expect(message).to be_acked
    end

    it 'increments `ack` in statsd' do
      expect(GovukStatsd).to receive(:increment).with("monitor.messages.ack.invalid_payload")
      subject.process(message)
    end
  end

  context 'with a transaction error' do
    context 'and message has not been redelivered' do
      let(:message) { build(:message) }

      before do
        allow(ActiveRecord::Base).to receive(:transaction).and_raise(StandardError)
      end

      it 'retries the message' do
        subject.process(message)
        expect(message).to be_retried
      end

      it 'increments `requeue` in statsd when error is raised' do
        expect(GovukStatsd).to receive(:increment).with("monitor.messages.requeue.error")
        subject.process(message)
      end
    end

    context 'and message is redelivered' do
      let(:message) { build(:message, redelivered?: true) }

      before do
        allow(ActiveRecord::Base).to receive(:transaction).and_raise(StandardError)
      end

      it 'discards the message' do
        subject.process(message)
        expect(message).to be_discarded
      end

      it 'increments `reject` in statsd when error is raised' do
        expect(GovukStatsd).to receive(:increment).with("monitor.messages.reject.error")
        subject.process(message)
      end
    end
  end
end
