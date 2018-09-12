module PublishingAPI
  class Consumer
    def process(message)
      if valid_routing_key?(message)
        MessageProcessorJob.perform_later(message.payload)
      else
        Monitor::Messages.increment_discarded
      end

      message.ack
    rescue StandardError => e
      GovukError.notify(e)
      message.discard
    end

  private

    def valid_routing_key?(message)
      routing_key = message.delivery_info.routing_key

      ROUTING_KEYS.any? { |suffix| routing_key.ends_with?(suffix) }
    end

    ROUTING_KEYS = %w(links major minor unpublish bulk.data-warehouse).freeze
  end
end
