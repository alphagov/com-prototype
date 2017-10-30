class Content::ItemDecorator < Draper::Decorator
  delegate_all

  def last_updated
    h.format_datetime(public_updated_at)
  end

  def feedex_link
    helpers.link_to "View feedback on FeedEx", "#{Plek.find('support')}/anonymous_feedback?path=#{object.base_path}"
  end

  def organisation_links
    names = object.linked_organisations.collect do |organisation|
      helpers.link_to(organisation.title, helpers.content_item_path(organisation.content_id))
    end

    names.join(', ').html_safe
  end

  def taxons_as_string
    object.linked_taxons.map(&:title).join(', ')
  end

  def topics
    titles(object.linked_topics)
  end

  def organisations
    titles(object.linked_organisations)
  end

  def policy_areas
    titles(object.linked_policy_areas)
  end

  def guidance
    h.format_boolean(guidance?)
  end

  def withdrawn
    h.format_boolean(withdrawn?)
  end

  def one_month_page_views
    h.format_number(object.one_month_page_views)
  end

  def six_months_page_views
    h.format_number(object.six_months_page_views)
  end

  def document_type
    object.document_type.titleize
  end

  def auditor
    allocation&.user&.name
  end

  def auditor_org
  allocation.user.organisation&.title
  end

  def auditor_gravatar_hash
    email = allocation&.user&.email&.downcase&.strip
    return nil unless email

    md5 = Digest::MD5.new
    md5 << email
    md5.hexdigest
  end

  def proxy_url
    File.join(Proxies::IframeAllowingProxy::PROXY_BASE_PATH, base_path)
  end

private

  def titles(content_items)
    h.format_array(content_items.map(&:title).sort)
  end
end
