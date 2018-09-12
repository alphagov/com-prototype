class Monitor::Messages
  def self.run(message)
    new.run(message)
  end

  def run(message)
    statsd_for_messages!(message)
  end

  def self.increment_discarded
    GovukStatsd.increment('monitor.messages.discarded')
  end

private

  def statsd_for_messages!(message)
    GovukStatsd.increment(monitoring_code(message.delivery_info['routing_key']))
  end

  def monitoring_code(routing_key)
    routing_key_type = routing_key.split('.').last
    "monitor.messages.#{routing_key_type}"
  end
end
