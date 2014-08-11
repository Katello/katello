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
    module Organization
      class Destroy < Actions::EntryAction

        def plan(organization, current_org = nil)
          action_subject(organization)

          validate(organization, current_org)

          concurrence do
            if ::Katello.config.use_cp
              sequence do
                # this will clean up systems, keys, etc in candlepin
                plan_action(Candlepin::Owner::Destroy, label:  organization.label)
                plan_action(Katello::Organization::IndexSubscriptions, organization)
              end
            end

            sequence do
              remove_consumers(organization)
              remove_content_view_environments(organization)
              remove_content_views(organization)
              remove_products(organization)
              remove_default_content_view(organization)
              organization.reload
              organization.destroy!
            end
          end
        end

        def humanized_name
          _("Destroy")
        end

        def validate(organization, current_org)
          errors = organization.validate_destroy(current_org)
          fail ::Katello::Errors::OrganizationDestroyException, errors.join(" ") if errors.present?
        end

        def remove_consumers(organization)
          concurrence do
            organization.systems.each do |system|
              plan_action(Katello::System::Destroy, system, skip_candlepin: true)
            end

            organization.activation_keys.each do |key|
              plan_action(Katello::ActivationKey::Destroy, key, skip_candlepin: true)
            end
          end
        end

        def remove_content_view_environments(organization)
          organization.content_view_environments.non_default.each do |cv_env|
            remove_content_view_environment(cv_env)
          end
        end

        def remove_content_view_environment(cv_env)
          plan_action(ContentViewEnvironment::Destroy, cv_env, skip_candlepin_update: true)
        end

        def remove_content_views(organization)
          concurrence do
            organization.content_views.non_default.each do |content_view|
              plan_action(ContentView::Destroy, content_view)
            end
          end
        end

        def remove_products(organization)
          concurrence do
            organization.products.each do |product|
              product.repositories.each do |repo|
                plan_action(Repository::Destroy, repo, skip_environment_update: true)
              end
              product.reload.destroy!
            end
          end
        end

        def remove_default_content_view(organization)
          organization.default_content_view.tap do |view|
            view.content_view_environments.each { |cve| remove_content_view_environment(cve) }
            plan_action(ContentView::Destroy, organization.default_content_view)
          end
        end
      end
    end
  end
end
