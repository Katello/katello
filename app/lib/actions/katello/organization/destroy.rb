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
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(organization, current_org = nil)
          action_subject(organization)

          validate(organization, current_org)

          sequence do
            remove_consumers(organization)
            remove_content_views(organization)
            remove_default_content_view(organization)
            remove_products(organization)
            remove_providers(organization)
            remove_environments(organization)
            destroy_contents(organization)
            plan_self
            plan_action(Candlepin::Owner::Destroy, label:  organization.label) if ::Katello.config.use_cp
            plan_action(Candlepin::Product::DeleteUnused, organization)
            plan_action(Katello::Organization::IndexSubscriptions, organization) if ::Katello.config.use_cp
          end
        end

        def finalize
          organization = ::Organization.find(input[:organization][:id])
          organization.destroy!
        end

        def humanized_name
          _("Destroy")
        end

        def validate(organization, current_org)
          errors = organization.validate_destroy(current_org)
          fail ::Katello::Errors::OrganizationDestroyException, errors.join(" ") if errors.present?
        end

        def remove_providers(organization)
          concurrence do
            organization.providers.each do |provider|
              plan_action(Katello::Provider::Destroy, provider, false)
            end
          end
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

        def remove_environments(organization)
          organization.promotion_paths.each do |path|
            path.reverse.each do |env|
              plan_action(Katello::Environment::Destroy, env, :skip_repo_destroy => true, :organization_destroy => true)
            end
          end
          plan_action(Katello::Environment::Destroy, organization.library, :skip_repo_destroy => true, :organization_destroy => true)
        end

        def remove_content_view_environment(cv_env)
          plan_action(ContentViewEnvironment::Destroy, cv_env, :skip_repo_destroy => true, :skip_candlepin_update => true, :organization_destroy => true)
        end

        def remove_content_views(organization)
          concurrence do
            organization.content_views.non_default.each do |content_view|
              plan_action(ContentView::Destroy, content_view, :check_ready_to_destroy => false, :organization_destroy => true)
            end
          end
        end

        def remove_products(organization)
          concurrence do
            organization.products.each do |product|
              plan_action(Product::Destroy, product, :organization_destroy => true)
            end
          end
        end

        def remove_default_content_view(organization)
          organization.default_content_view.tap do |view|
            view.content_view_environments.each { |cve| remove_content_view_environment(cve) }
            plan_action(ContentView::Destroy, organization.default_content_view, :check_ready_to_destroy => false, :organization_destroy => true)
          end
        end

        def destroy_contents(organization)
          repositories = organization.products.map(&:repositories).flatten
          content_ids = repositories.map(&:content_id).uniq
          content_ids.each do |content_id|
            plan_action(Candlepin::Product::ContentDestroy,
                        content_id: content_id)
          end
        end
      end
    end
  end
end
