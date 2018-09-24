class Reports::Content
  def self.retrieve(from:, to:, organisation_id:)
    new(from, to, organisation_id).retrieve
  end

  def initialize(from, to, organisation_id)
    @from = from
    @to = to
    @organsation_id = organisation_id
  end

  def retrieve
    Facts::Metric.all
      .joins(:dimensions_date).merge(slice_dates)
      .joins(:dimensions_item).merge(slice_items)
      .joins(latest_join)
      .group('latest.content_uuid', *group_columns)
      .order(order_by)
      .limit(100)
      .pluck(*group_columns, *aggregates)
      .map(&method(:array_to_hash))
  end

private

  def aggregates
    [
      sum('unique_pageviews'),
      sum('is_this_useful_yes'),
      sum('is_this_useful_no'),
      sum('number_of_internal_searches')
    ]
  end

  def group_columns
    %w[latest.base_path latest.title latest.document_type].map { |col| Arel.sql(col) }
  end

  def order_by
    Arel.sql('latest.content_uuid')
  end

  def sum(column)
    Arel.sql("SUM(#{column})")
  end

  def latest_join
    "INNER JOIN dimensions_items latest ON latest.content_uuid = dimensions_items.content_uuid AND latest.latest = true"
  end

  def array_to_hash(array)
    satisfaction_responses = array[4] + array[5]
    {
      base_path: array[0],
      title: array[1],
      document_type: array[2],
      unique_pageviews: array[3],
      satisfaction_score: satisfaction_responses.zero? ? nil : array[4].to_f / satisfaction_responses,
      satisfaction_score_responses: satisfaction_responses,
      number_of_internal_searches: array[6],
    }
  end

  def slice_items
    Dimensions::Item.by_organisation_id(@organsation_id)
  end

  def slice_dates
    Dimensions::Date.between(@from, @to)
  end
end
