class AddUniqueIndexToLastThreeMonths < ActiveRecord::Migration[5.2]
  def change
    add_index :aggregations_search_last_three_months, %i(dimensions_edition_id warehouse_item_id), unique: true, name: "index_on_search_last_three_months_unique"
  end
end
