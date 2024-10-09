require 'set'

module Actions
  module Katello
    module Repository
      class Destroy < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        # options:
        #   skip_environment_update - defaults to false. skips updating the CP environment
        #   destroy_content - can be disabled to skip Candlepin remove_content
        def plan(repository, options = {})
          affected_cvv_ids = []
          skip_environment_update = options.fetch(:skip_environment_update, false) ||
              options.fetch(:organization_destroy, false)
          destroy_content = options.fetch(:destroy_content, true)
          remove_from_content_view_versions = options.fetch(:remove_from_content_view_versions, false)
          delete_empty_repo_filters = options.fetch(:delete_empty_repo_filters, true)
          docker_cleanup = options.fetch(:docker_cleanup, true)
          action_subject(repository)
          check_destroyable!(repository, remove_from_content_view_versions)
          remove_generated_content_views(repository)

          remove_versions(repository, repository.content_views.generated_for_library, affected_cvv_ids)

          plan_action(Actions::Pulp3::Orchestration::Repository::Delete,
                           repository,
                           SmartProxy.pulp_primary)

          remove_versions(repository, repository.content_views_all(include_composite: true)&.generated_for_none, affected_cvv_ids) if remove_from_content_view_versions

          handle_acs_product_removal(repository)
          handle_alternate_content_sources(repository)
          delete_empty_repo_filters(repository) if delete_empty_repo_filters

          plan_self(:user_id => ::User.current.id, :affected_cvv_ids => affected_cvv_ids, :docker_cleanup => docker_cleanup)
          sequence do
            if repository.redhat?
              handle_redhat_content(repository) unless skip_environment_update
            else
              if destroy_content && !skip_environment_update
                handle_custom_content(repository, remove_from_content_view_versions)
              end
            end
          end
        end

        def finalize
          repository = ::Katello::Repository.find_by(id: input[:repository][:id])
          if repository
            docker_cleanup = repository.docker? && input[:docker_cleanup]
            delete_record(repository, {docker_cleanup: docker_cleanup})

            if (affected_cvv_ids = input[:affected_cvv_ids]).any?
              cvvs = ::Katello::ContentViewVersion.where(id: affected_cvv_ids)
              cvvs.each do |cvv|
                cvv.update_content_counts!
              end
            end
          end
        end

        def handle_alternate_content_sources(repository)
          repository.smart_proxy_alternate_content_sources.each do |smart_proxy_acs|
            plan_action(Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs)
          end
        end

        def handle_acs_product_removal(repository)
          # Remove products from ACS's that contain no repositories which both
          # match the ACS content type and have a non-nil URL
          product = repository.product
          repo_content_types = Set.new
          product.repositories.each do |test_repo|
            # we need to check id because test_repo will still contain the old, non-nil url
            repo_content_types.add(test_repo.content_type) if (repository.id != test_repo.id) && test_repo.url.present?
          end
          ::Katello::AlternateContentSource.with_products(product).each do |acs|
            unless repo_content_types.include?(acs.content_type)
              acs.products = acs.products - [product]
              Rails.logger.info _('Removing product %{prod_name} with ID %{prod_id} from ACS %{acs_name} with ID %{acs_id}') %
                { prod_name: product.name, prod_id: product.id, acs_name: acs.name, acs_id: acs.id }
            end
          end
        end

        def delete_empty_repo_filters(repository)
          filters_to_delete = repository.filters.select { |filter| filter.repositories.size == 1 }
          ::Katello::ContentViewFilter.where(id: filters_to_delete).destroy_all
        end

        def handle_custom_content(repository, remove_from_content_view_versions)
          #if this is the last instance of a custom repo or a deb repo using structured APT, destroy the content
          if remove_from_content_view_versions || repository.root.repositories.where.not(id: repository.id).empty? || repository.deb_using_structured_apt?
            plan_action(::Actions::Katello::Product::ContentDestroy, repository)
          end
        end

        def handle_redhat_content(repository)
          if repository.content_view.content_view_environment(repository.environment)
            plan_action(Candlepin::Environment::SetContent, repository.content_view, repository.environment, repository.content_view.content_view_environment(repository.environment))
          end
        end

        def delete_record(repository, options = {})
          ::Katello::SyncPlan.remove_disabled_product(repository) if repository.redhat?
          repository.destroy!
          repository.root.destroy! if repository.root.repositories.empty?
          ::Katello::DockerMetaTag.cleanup_tags if options[:docker_cleanup]
        end

        def remove_generated_content_views(repository)
          # remove the content views generated for this repository (since we are deleting the repo)
          content_views = repository.content_views.generated_for_repository
          return if content_views.blank?
          plan_action(::Actions::BulkAction, ::Actions::Katello::ContentView::Remove,
                        content_views,
                        skip_repo_destroy: true,
                        destroy_content_view: true)
        end

        def remove_versions(repository, content_views, affected_cvv_ids)
          return if content_views.blank?
          interested_inverses = repository.
                                  library_instances_inverse.
                                  joins(:content_view_version => :content_view).
                                  merge(content_views)
          return if interested_inverses.blank?
          affected_cvv_ids.concat(interested_inverses.pluck(:content_view_version_id)&.uniq)
          plan_action(::Actions::BulkAction, ::Actions::Katello::Repository::Destroy, interested_inverses)
        end

        def check_destroyable!(repository, remove_from_content_view_versions)
          unless repository.destroyable?(remove_from_content_view_versions)
            # The repository is going to be deleted in finalize, but it cannot be deleted.
            # Stop now and inform the user.
            fail repository.errors.messages.values.join("\n")
          end
        end

        def humanized_name
          _("Delete")
        end
      end
    end
  end
end
