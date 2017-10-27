module Audits
  class BaseController < ApplicationController
    layout "audits"
    helper_method :filter, :filter_params

    def filter(override = {})
      options = default_filter
        .merge(filter_from_non_blankable_query_parameters)
        .merge(filter_from_blankable_query_parameters)
        .merge(override)

      Filter.new(options)
    end

  private

    def default_filter
      @default_filter || {
        allocated_to: :anyone,
        audit_status: Audits::Audit::NON_AUDITED,
        primary_org_only: true,
      }
    end

    def filter_from_non_blankable_query_parameters
      options = {
        allocated_to: params[:allocated_to],
        audit_status: params[:audit_status],
        document_type: params[:document_type],
        page: params[:page],
        sort: Sort.column(params[:sort_by]),
        sort_direction: Sort.direction(params[:sort_by]),
        title: params[:query],
      }

      options.delete_if { |_, v| v.blank? }
    end

    def filter_from_blankable_query_parameters
      {}.tap do |options|
        options[:primary_org_only] = primary_org_only? if params.key?(:primary)
        options[:organisations] = array_param(:organisations) if params.key?(:organisations)
        options[:topics] = array_param(:topics) if params.key?(:topics)
      end
    end

    def filter_params
      Audits::SerializeFilterToQueryParameters
        .new(filter)
        .call
    end

    def primary_org_only?
      params[:primary] == "true"
    end

    def array_param(key)
      params
        .fetch(key, [])
        .flatten
        .reject(&:blank?)
    end
  end
end
