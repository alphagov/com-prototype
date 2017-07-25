RSpec.describe Search::Sort do
  describe "apply" do
    it "sorts a scope based on the sort query" do
      scope = double
      sort = Search::Sort.new(:identifier, :sort_query, :next_item_criteria)

      expect(scope).to receive(:order).with(:sort_query)
      sort.apply(scope)
    end
  end
end
