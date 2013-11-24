module Orchestrate
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
          [part, humanize_resource(part, @input[part])]
        end
      end

      def included_parts(parts, data)
        parts.select { |part| data.has_key?(part) }
      end

      def humanize_resource(type, data)
        humanized_type = _(type)
        humanized_value = data[:name] || data[:label] || data[:id]
        { text: "#{humanized_type} '#{humanized_value}'",
         link: link_to_resource(type, data) }
      end

      def link_to_resource(type, data)
        "/hello/kitty"
      end
    end
  end
end
