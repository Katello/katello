module Actions
  module Helpers

    class Humanizer

      PARTS_ORDER = [:repository,
                     :product,
                     :system,
                     :organization]
      # Just to get the trings into pot file
      PARTS_TRANSLATIONS = [N_('repository'),
                            N_('product'),
                            N_('system'),
                            N_('organization')]

      def initialize(action)
        @action = action
        @input  = action.respond_to?(:task_input) ? action.task_input : action.input
        @input ||= {}
        @output = action.respond_to?(:task_output) ? action.task_output : action.output
        @output ||= {}
      end

      def input(*parts)
        if parts.empty?
          parts = PARTS_ORDER
        end
        included_parts(parts, @input).map do |part|
          [part, humanize_resource(part, @input[part], @input)]
        end
      end

      def included_parts(parts, data)
        parts.select { |part| data.has_key?(part) }
      end

      def humanize_resource(type, data, other_data)
        humanized_type = _(type)
        humanized_value = data[:name] || data[:label] || data[:id]
        { text: "#{humanized_type} '#{humanized_value}'",
         link: link_to_resource(type, data, other_data) }
      end

      def link_to_resource(type, data, other_data)
        case type
        when :product
          "#/products/#{data[:cp_id]}/info" if data[:cp_id]
        when :repository
          if other_data[:product] && other_data[:product][:cp_id] && data[:id]
            "#/products/#{other_data[:product][:cp_id]}/repositories/#{data[:id]}"
          end
        when :system
          if data[:uuid]
            "#/systems/#{data[:uuid]}/info"
          end
        when :organization
          if data[:label]
            "/katello/organizations#/!=&panel=organization_#{data[:label]}&!="
          end
        end
      end
    end
  end
end
