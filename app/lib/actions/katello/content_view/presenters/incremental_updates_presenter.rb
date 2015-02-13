#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Actions
  module Katello
    module ContentView
      module Presenters
        class IncrementalUpdatesPresenter < Helpers::Presenter::Base
          HUMANIZED_TYPES = {
            ::Katello::Erratum::CONTENT_TYPE => "Errata",
            ::Katello::Package::CONTENT_TYPE => "Packages",
            ::Katello::PuppetModule::CONTENT_TYPE => "Puppet Modules"
          }

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
              cvv = ::Katello::ContentViewVersion.find_by_id(output[:content_view_version][:id])
              if cvv
                humanized_lines << "Content View: #{cvv.content_view.name} version #{cvv.version}"
                humanized_lines << _("Added Content:")
                [::Katello::Erratum, ::Katello::Package, ::Katello::PuppetModule].each do |content_type|
                  unless output[:added_units][content_type::CONTENT_TYPE].blank?
                    humanized_lines << "  #{HUMANIZED_TYPES[content_type::CONTENT_TYPE]}:"
                    humanized_lines += output[:added_units][content_type::CONTENT_TYPE].map { |unit| "        #{unit}" }
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
