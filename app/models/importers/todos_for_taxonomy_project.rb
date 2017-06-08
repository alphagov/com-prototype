module Importers
  class TodosForTaxonomyProject
    def initialize(group_name, csv_parser)
      @name = group_name
      @csv_parser = csv_parser
    end

    def run
      TaxonomyTodo.transaction do
        @csv_parser.each_row do |row|
          content_item = ContentItem.find_by(content_id: row['content_id'])
          if content_item
            TaxonomyTodo.create(
              taxonomy_project: project,
              content_item: content_item
            )
          end
        end
      end
    end

  private

    def project
      @_project ||= TaxonomyProject.create(name: @name)
    end
  end
end
