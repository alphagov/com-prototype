class Aggregations::Base < ApplicationRecord
  def self.refresh
    Aggregations::MaterializedView.prepare
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: false)
  end
end
