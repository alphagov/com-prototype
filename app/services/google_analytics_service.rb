class GoogleAnalyticsService
  def client
    @client ||= GoogleAnalytics::Client.new.build
  end

  def page_views(base_paths)
    raise "base_paths isn't an array" unless base_paths.is_a?(Array)

    request = GoogleAnalytics::Requests::PageViewsRequest.new.build(
      base_paths: base_paths,
      start_dates: [1.month.ago.strftime("%Y-%m-%d"), 6.months.ago.strftime("%Y-%m-%d")]
    )
    response = client.batch_get_reports(request)
    GoogleAnalytics::Responses::PageViewsResponse.new.parse(response)
  end
end
