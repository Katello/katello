module Actions
  module Katello
    module ContentView
      module Presenters
        class IncrementalUpdatesPresenter < Helpers::Presenter::Base
          HUMANIZED_TYPES = {
            ::Katello::Erratum::CONTENT_TYPE => "Errata",
            ::Katello::Rpm::CONTENT_TYPE => "Packages",
            ::Katello::PuppetModule::CONTENT_TYPE => "Puppet Modules"
          }.freeze

          def humanized_output
            if action.output[:changed_content]
              humanized_content
            else
              _("Incremental Update incomplete.")
            end
          end

          def humanized_content
            humanized_lines = []

            action.output[:changed_content].each do |output|
              cvv = ::Katello::ContentViewVersion.find_by(:id => output[:content_view_version][:id])
              if cvv
                humanized_lines << "Content View: #{cvv.content_view.name} version #{cvv.version}"
                humanized_lines << _("Added Content:")
                [::Katello::Erratum, ::Katello::Rpm, ::Katello::PuppetModule].each do |content_type|
                  unless output[:added_units][content_type::CONTENT_TYPE].blank?
                    humanized_lines << "  #{HUMANIZED_TYPES[content_type::CONTENT_TYPE]}:"
                    humanized_lines += output[:added_units][content_type::CONTENT_TYPE].sort.map { |unit| "        #{unit}" }
                  end
                end
                humanized_lines << ''
              end
            end
            humanized_lines.join("\n")
          end
        end
      end
    end
  end
end
