require_relative '../../app/streams/publishing_api/consumer'

namespace :publishing_api do
  desc "Run worker to publishing API from rabbitmq"
  task consumer: :environment do
    GovukMessageQueueConsumer::Consumer.new(
      queue_name: "content_performance_manager",
      processor: PublishingAPI::Consumer.new,
    ).run
  end

  desc "Run worker to publishing API from rabbitmq for bulk import"
  task bulk_import_consumer: :environment do
    GovukMessageQueueConsumer::Consumer.new(
      queue_name: "content_performance_manager_govuk_importer",
      processor: PublishingAPI::Consumer.new,
    ).run
  end
end
