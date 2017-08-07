module ReportHelper
  def audited_count
    Audits::ContentQuery
      .new(scope: @content_query.scope)
      .audited
      .content_items
      .total_count
  end

  def not_audited_count
    Audits::ContentQuery
      .new(scope: @content_query.scope)
      .non_audited
      .content_items
      .total_count
  end

  def audited_percentage
    percentage(audited_count, out_of: @content_items.total_count)
  end

  def not_audited_percentage
    percentage(not_audited_count, out_of: @content_items.total_count)
  end

  def passing_count
    Audits::ContentQuery
      .new(scope: @content_query.scope)
      .passing
      .content_items
      .total_count
  end

  def not_passing_count
    Audits::ContentQuery
      .new(scope: @content_query.scope)
      .failing
      .content_items
      .total_count
  end

  def passing_percentage
    percentage(passing_count, out_of: audited_count)
  end

  def not_passing_percentage
    percentage(not_passing_count, out_of: audited_count)
  end

private

  def percentage(number, out_of:)
    return 0 if out_of.zero?
    number.to_f / out_of * 100
  end
end
