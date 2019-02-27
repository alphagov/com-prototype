select dimensions_editions.warehouse_item_id as warehouse_item_id,
  dimensions_editions.title as title,
  dimensions_editions.document_type as document_type,
  dimensions_editions.base_path as base_path,
  dimensions_editions.organisation_id as organisation_id,
  dimensions_editions.id as dimensions_edition_id,
  aggregations.upviews as upviews,
  aggregations.pviews as pviews,
  aggregations.feedex as feedex,
  aggregations.useful_yes as useful_yes,
  aggregations.useful_no as useful_no,
  calculate_satisfaction(useful_yes, useful_no) as satisfaction,
  aggregations.searches as searches,
  facts_editions.words as words,
  facts_editions.pdf_count as pdf_count,
  facts_editions.reading_time as reading_time
FROM
  (
      SELECT  warehouse_item_id,
      max(aggregations_monthly_metrics.dimensions_edition_id) AS dimensions_edition_id,
      sum(aggregations_monthly_metrics.upviews) AS upviews,
      sum(aggregations_monthly_metrics.pviews) AS pviews,
      sum(aggregations_monthly_metrics.useful_yes) AS useful_yes,
      sum(aggregations_monthly_metrics.useful_no) AS useful_no,
      sum(aggregations_monthly_metrics.feedex) AS feedex,
      sum(aggregations_monthly_metrics.searches) AS searches
    FROM aggregations_monthly_metrics
    INNER JOIN dimensions_months ON dimensions_months.id = aggregations_monthly_metrics.dimensions_month_id
    INNER JOIN dimensions_editions ON dimensions_editions.id = aggregations_monthly_metrics.dimensions_edition_id
    WHERE dimensions_months.id = to_char(NOW() - interval '1 month','YYYY-MM')
    GROUP BY warehouse_item_id
  ) as aggregations
INNER JOIN dimensions_editions ON aggregations.dimensions_edition_id = dimensions_editions.id
INNER JOIN facts_editions ON dimensions_editions.id = facts_editions.dimensions_edition_id
WHERE dimensions_editions.document_type NOT IN ('gone','vanish','need','unpublishing','redirect')
