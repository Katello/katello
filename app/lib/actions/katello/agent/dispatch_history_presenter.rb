module Actions
  module Katello
    module Agent
      class DispatchHistoryPresenter
        def initialize(dispatch_history, action_type)
          @result = dispatch_history&.result&.with_indifferent_access
          @action_type = action_type
        end

        def humanized_output
          return if @result.empty?

          result = package_result

          if result[:message]
            result[:message]
          elsif result[:packages].any?
            packages = result[:packages].map { |package| package[:qname] }
            packages.sort.join("\n")
          else
            humanized_no_package
          end
        end

        def error_messages
          messages = []
          @result.each_value do |result|
            if !result[:succeeded] && result.dig(:details, :message)
              messages << result[:details][:message]
            end
          end
          messages
        end

        private

        def package_result
          result = { packages: [] }

          @result.each_value do |v|
            if v[:succeeded]
              result[:packages].concat(v[:details][:resolved] + v[:details][:deps])
              break
            else
              result[:message] = v[:details][:message]
              break
            end
          end

          result
        end

        def humanized_no_package
          case @action_type
          when :content_install
            _("No new packages installed")
          when :content_uninstall
            _("No packages removed")
          end
        end
      end
    end
  end
end
