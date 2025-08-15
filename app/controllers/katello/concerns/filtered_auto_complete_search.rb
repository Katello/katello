module Katello
  module Concerns
    module FilteredAutoCompleteSearch
      extend ActiveSupport::Concern

      PAGE_SIZE = 20

      def auto_complete_search
        begin
          options = resource_class.respond_to?(:completer_scope_options) ? resource_class.completer_scope_options(params[:search]) : {}
          if resource_class < Authorizable
            permission = resource_class.find_permission_name(:view)
            resource_class = resource_class.authorized(permission)
          end
          items = resource_class.where(:id => self.index_relation).complete_for(params[:search], options)
          items = filter_autocomplete_items(items)
          items = items.map do |item|
            category = ['and', 'or', 'not', 'has'].include?(item.to_s.sub(/^.*\s+/, '')) ? _('Operators') : ''
            part = item.to_s.sub(/^.*\b(and|or)\b/i) { |match| match.sub(/^.*\s+/, '') }
            completed = item.to_s.chomp(part)
            {:completed => completed, :part => part, :label => item, :category => category}
          end
        rescue ScopedSearch::QueryNotSupported => e
          items = [{:error => e.to_s}]
        end
        render :json => items
      end

      protected

      def filter_autocomplete_items(items)
        rejected_patterns = rejected_autocomplete_items
        return items if rejected_patterns.empty?

        items.reject do |item|
          item_string = item.to_s.downcase
          rejected_patterns.any? { |pattern| item_string.include?(pattern.downcase) }
        end
      end

      def rejected_autocomplete_items
        []
      end
    end
  end
end
