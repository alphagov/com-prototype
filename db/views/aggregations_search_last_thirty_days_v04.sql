SELECT warehouse_item_id,
  max(facts_metrics.dimensions_edition_id) AS dimensions_edition_id,
  sum(facts_metrics.upviews) AS upviews,
  sum(facts_metrics.pviews) AS pviews,
  sum(facts_metrics.useful_yes) AS useful_yes,
  sum(facts_metrics.useful_no) AS useful_no,
  sum(facts_metrics.feedex) AS feedex,
  sum(facts_metrics.searches) AS searches
 FROM facts_metrics
   JOIN dimensions_dates ON dimensions_dates.date = facts_metrics.dimensions_date_id
   JOIN dimensions_editions ON dimensions_editions.id = facts_metrics.dimensions_edition_id
 WHERE (facts_metrics.dimensions_date_id > (('yesterday'::text)::date - '30 days'::interval day))
   AND (facts_metrics.dimensions_date_id < ('now'::text)::date)
GROUP BY warehouse_item_id