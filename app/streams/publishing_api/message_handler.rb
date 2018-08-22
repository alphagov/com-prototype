class PublishingAPI::MessageHandler
  def self.process(*args)
    new(*args).process
  end

  def initialize(message)
    @message = message
  end

  def process
    return if PublishingAPI::MessageValidator.is_old_message?(message)
    if PublishingAPI::MultipartMessage.is_multipart?(message)
      PublishingAPI::MultipartHandler.process(message)
    else
      PublishingAPI::SingleItemHandler.process(message)
    end

  end

private

  attr_reader :message
end
