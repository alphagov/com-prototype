class Streams::Handlers::SingleItemHandler < Streams::Handlers::BaseHandler
  def self.process(*args)
    new(*args).process
  end

  def initialize(attrs)
    @attrs = attrs
  end

  attr_reader :attrs, :old_edition

  def process
    update_editions [attrs: attrs, old_edition: find_old_edition(attrs[:content_id], attrs[:locale])]
  end

private

  def find_old_edition(content_id, locale)
    Dimensions::Edition.find_by(content_id: content_id, locale: locale, latest: true)
  end
end