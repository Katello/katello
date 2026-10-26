module Actions
  module Katello
    module Repository
      class Update < Actions::EntryAction
        def plan(root, repo_params)
          repository = root.library_instance
          action_subject root.library_instance

          repo_params[:url] = nil if repo_params[:url] == ''
          repo_params[:checksum_type] = nil if repo_params[:download_policy] == ::Katello::RootRepository::DOWNLOAD_ON_DEMAND
          update_cv_cert_protected = repo_params.key?(:unprotected) && (repo_params[:unprotected] != repository.unprotected)
          create_acs = create_acs?(repository.url, repo_params[:url])
          delete_acs = delete_acs?(repository.url, repo_params[:url])

          # Keep the old URL for RPM vs ULN remote cleanup
          old_url = root.url

          # Validate docker repository distribution paths before updating
          # This catches both pre-existing overlaps (from before Pulp 3.105) and new overlaps
          # from name changes, preventing paused tasks during RefreshDistribution
          validate_docker_distribution_path!(repository, root, repo_params) if repository.docker?

          root.update!(repo_params)

          # For docker repos, recalculate container_repository_name on library instance after root changes
          # Reload clears cached root association so before_validation callback sees new docker_upstream_name
          if repository.docker? && repo_params.key?(:docker_upstream_name)
            repository.reload.save!
          end

          if update_content?(repository)
            plan_action(::Actions::Candlepin::Product::ContentUpdate,
                        owner:           repository.organization.label,
                        repository_id:   repository.id,
                        name:            root.name,
                        type:            root.content_type,
                        arches:          root.format_arches,
                        label:           repository.content.label,
                        content_url:     root.custom_content_path,
                        gpg_key_url:     repository.yum_gpg_key_url,
                        os_versions:     root.os_versions&.join(','),
                        metadata_expire: root.metadata_expire)
          end

          if root.pulp_update_needed?
            sequence do
              plan_action(::Actions::Pulp3::Orchestration::Repository::Update,
                               repository,
                               SmartProxy.pulp_primary)
              plan_self(:repository_id => root.library_instance.id)
              if update_cv_cert_protected
                smart_proxy = ::SmartProxy.pulp_primary
                if smart_proxy.pulp3_support?(repository)
                  plan_action(::Actions::Pulp3::Orchestration::Repository::TriggerUpdateRepoCertGuard, repository, smart_proxy)
                end
              end

              handle_alternate_content_sources(repository, create_acs, delete_acs, old_url)
            end
          end
        end

        def run
          repository = ::Katello::Repository.find(input[:repository_id])
          ForemanTasks.async_task(Katello::Repository::MetadataGenerate, repository)
          repository.clear_smart_proxy_sync_histories
        end

        private

        def handle_alternate_content_sources(repository, create_acs, delete_acs, old_url)
          if create_acs
            repository.product.alternate_content_sources.each do |acs|
              acs.smart_proxies.each do |smart_proxy|
                smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id, repository_id: repository.id)
                plan_action(Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
              end
            end
          elsif delete_acs
            handle_acs_product_removal(repository)
            repository.smart_proxy_alternate_content_sources.each do |smart_proxy_acs|
              plan_action(Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs, old_url: old_url)
            end
          else
            repository.smart_proxy_alternate_content_sources.each do |smart_proxy_acs|
              plan_action(Pulp3::Orchestration::AlternateContentSource::Update, smart_proxy_acs)
            end
          end
        end

        def handle_acs_product_removal(repository)
          # Remove products from ACS's that contain no repositories which both
          # match the ACS content type and have a non-nil URL
          product = repository.product
          repo_content_types = ::Katello::RootRepository.where(:id => product.repositories.where.not(:id => repository.id).select(:root_id)).where.not(:url => [nil, '']).distinct.pluck(:content_type)
          ::Katello::AlternateContentSource.with_products(product).each do |acs|
            unless repo_content_types.include?(acs.content_type)
              acs.products = acs.products - [product]
              Rails.logger.info _('Removing product %{prod_name} with ID %{prod_id} from ACS %{acs_name} with ID %{acs_id}') %
                { prod_name: product.name, prod_id: product.id, acs_name: acs.name, acs_id: acs.id }
            end
          end
        end

        def update_content?(repository)
          repository.library_instance? && !repository.product.redhat?
        end

        def create_acs?(old_url, new_url)
          (old_url.nil? || old_url.start_with?('uln')) && new_url.present? && !new_url.start_with?('uln')
        end

        def delete_acs?(old_url, new_url)
          old_url.present? && (new_url.nil? || new_url.start_with?('uln'))
        end

        def validate_docker_distribution_path!(_repository, root, repo_params)
          # Validate across ALL environments where this root has repositories
          # When updating docker_upstream_name, it affects all repos of this root across all environments
          environments_to_check = root.repositories.where.not(environment_id: nil).pluck(:environment_id).uniq
          return if environments_to_check.empty?

          environments_to_check.each do |env_id|
            environment = ::Katello::KTEnvironment.find(env_id)
            registry_pattern = environment.registry_name_pattern

            # Find the repository in this environment (if it exists)
            repo_in_env = root.repositories.find_by(environment_id: env_id)
            next unless repo_in_env

            # Get all docker repositories in this environment, excluding repos from this root
            existing_repos = environment.repositories.docker_type.where.not(root_id: root.id)

            # Render what the NEW path will be after applying repo_params
            new_path = normalize_path(render_new_container_path(repo_in_env, root, repo_params, registry_pattern, environment))
            next if new_path.blank? # Nothing to validate if path is blank

            # Check if new path would overlap with any existing repo
            existing_repos.each do |existing_repo|
              existing_path = normalize_path(existing_repo.container_repository_name)
              next if existing_path.blank? # Skip repos without a path

              # Check both directions: new could be parent or child of existing
              if new_path.start_with?(existing_path + '/') || existing_path.start_with?(new_path + '/')
                parent_path, child_path = new_path.size < existing_path.size ? [new_path, existing_path] : [existing_path, new_path]
                error_msg = ::Katello::ContentView.container_overlap_error(parent_path, child_path)
                fail ::Katello::HttpErrors::Conflict, [error_msg, ::Katello::ContentView.consider_changing_pattern_message].join("  ")
              end

              # Check for exact duplicates
              if new_path == existing_path
                error_msg = _("Repository name would result in duplicate container image path '%{path}' with repository '%{name}'.") % { path: new_path, name: existing_repo.name }
                fail ::Katello::HttpErrors::Conflict, [error_msg, ::Katello::ContentView.consider_changing_pattern_message].join("  ")
              end
            end
          end
        end

        def normalize_path(path)
          # Remove trailing slashes to ensure consistent comparison
          path&.sub(%r{/+$}, '')
        end

        def render_new_container_path(repository, root, repo_params, registry_pattern, _environment)
          # Use dup to safely apply new params without modifying the original objects
          # This lets us render what the path WILL BE after update, before actually updating
          temp_root = root.dup
          temp_root.assign_attributes(repo_params.slice(:name, :docker_upstream_name))
          temp_repo = repository.dup
          temp_repo.root = temp_root

          ::Katello::Repository.safe_render_container_name(temp_repo, registry_pattern)
        end
      end
    end
  end
end
