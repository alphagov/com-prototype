module Content
  class Query
    def initialize(scope = Content::Item.all)
      @scope = scope
      @page = 1
      @per_page = 25
      @sort = :six_months_page_views
      @sort_direction = :desc
    end

    def page(page)
      set(:page, page)
    end

    def per_page(per_page)
      set(:per_page, per_page)
    end

    def sort(sort)
      set(:sort, sort)
    end

    def sort_direction(sort_direction)
      set(:sort_direction, sort_direction)
    end

    def title(title)
      builder(verify_presence: title) do
        @scope = @scope.where("title like ?", "%#{title}%")
      end
    end

    def document_types(*document_types)
      document_types.compact!
      document_types.reject!(&:empty?)

      builder(verify_presence: document_types) do
        @scope = @scope.where(document_type: document_types)
      end
    end

    def primary_organisation(organisation)
      builder(verify_presence: organisation) do
        apply_link_filter(
          link_type: Content::Link::PRIMARY_ORG,
          target_ids: organisation,
        )
      end
    end

    def organisations(organisations, primary = false)
      builder(verify_presence: organisations) do
        if primary
          primary_organisation(organisations)
        else
          apply_link_filter(
            link_type: Content::Link::ALL_ORGS,
            target_ids: organisations,
          )
        end
      end
    end

    def policies(policies)
      builder(verify_presence: policies) do
        apply_link_filter(
          link_type: Content::Link::POLICIES,
          target_ids: policies,
        )
      end
    end

    def taxons(taxons)
      builder(verify_presence: taxons) do
        apply_link_filter(
          link_type: Content::Link::TAXONOMIES,
          target_ids: taxons,
        )
      end
    end

    def theme(identifier)
      builder(verify_presence: identifier) do
        type, id = identifier.to_s.split("_")
        return self unless %(Theme Subtheme).include?(type)

        model = Audits.const_get(type).find(id)
        filter = RulesFilter.new(rules: model.inventory_rules)
        @scope = filter.apply(@scope)
      end
    end

    def after(content_item)
      builder(verify_presence: content_item) do
        @after = content_item
      end
    end

    def scope
      scope = @scope.clone
      scope = apply_ordering(scope)
      scope = apply_pagination(scope)
      apply_after(scope)
    end

    def content_items
      scope
    end

    def all_content_items
      scope.limit(nil).offset(nil)
    end

    def clone
      Marshal.load(Marshal.dump(self))
    end

  private

    def apply_link_filter(link_type:, source_ids: nil, target_ids: nil)
      filter = LinkFilter.new(
        link_type: link_type,
        source_ids: source_ids,
        target_ids: target_ids,
      )

      @scope = filter.apply(@scope)
    end

    def apply_ordering(scope)
      scope.order(
        @sort => @sort_direction,
        # Finally sort by Content ID (which is unique) to stabilise sort order
        :content_id => @sort_direction,
      )
    end

    def apply_pagination(scope)
      scope.page(@page).per(@per_page)
    end

    def apply_after(scope)
      return scope unless @after

      sort_field = Content::Item.arel_table[@sort]
      content_id_field = Content::Item.arel_table[:content_id]

      comparison = @sort_direction == :asc ? :gt : :lt

      scope.where(
        sort_field.send(comparison, @after[@sort])
          .or(
            sort_field.eq(@after[@sort])
              .and(content_id_field.send(comparison, @after[:content_id]))
          )
      )
    end

    def set(instance_variable, value)
      builder(verify_presence: value) do
        instance_variable_set("@#{instance_variable}", value)
      end
    end

    def builder(verify_presence:)
      yield if verify_presence.present?

      self
    end
  end
end
