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
    module ContentViewPuppetModule
      class Destroy < Actions::EntryAction
        def plan(repository)
          action_subject(repository)

          # For each puppet module in the repository, if the module exists
          # only in this repository, then locate and destroy all content view
          # puppet modules that are referring to it
          repository.puppet_modules.each do |puppet_module|
            # first, process content view puppet modules that have been specified by version
            library_repos = ::Katello::Repository.in_environment(repository.organization.library).
                                                  where(:pulp_id => puppet_module.repoids)

            if library_repos.length == 1
              content_view_puppet_modules = ::Katello::ContentViewPuppetModule.joins(:content_view).
                  where("#{::Katello::ContentView.table_name}.organization_id" => repository.organization.id).
                  where(:uuid => puppet_module.id)

              content_view_puppet_modules.destroy_all
            end

            # second, process content view puppet modules that have been specified by name/author (i.e. latest version)
            content_view_puppet_modules = ::Katello::ContentViewPuppetModule.joins(:content_view).
                where("#{::Katello::ContentView.table_name}.organization_id" => repository.organization.id).
                where(:name => puppet_module.name).where(:author => puppet_module.author)

            if content_view_puppet_modules.any?
              puppet_repoids = ::Katello::Repository.puppet_type.in_environment(repository.organization.library).
                  pluck(:pulp_id).reject { |repoid| repoid == repository.pulp_id }
              found_puppet_module = ::Katello::PuppetModule.latest_modules_search([{:name => puppet_module.name,
                                                                                    :author => puppet_module.author}],
                                                                                  puppet_repoids).first

              content_view_puppet_modules.destroy_all unless found_puppet_module
            end
          end
        end

        def humanized_name
          _("Delete")
        end
      end
    end
  end
end
