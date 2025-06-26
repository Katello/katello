module Actions
  module Katello
    module Flatpak
      class MirrorRemoteRepository < Actions::EntryAction
        def plan(remote_repository, product)
          action_subject(remote_repository)
          repo_params = {
            name: remote_repository.name,
            label: remote_repository.label,
            url: remote_repository.flatpak_remote&.registry_url,
            description: 'Mirrored from: ' + remote_repository.flatpak_remote.name,
            product_id: product.id,
            content_type: 'docker',
            docker_upstream_name: remote_repository.name,
            include_tags: ["latest"],
            upstream_username: remote_repository.flatpak_remote.username,
            upstream_password: remote_repository.flatpak_remote.token,
            unprotected: true,
            mirroring_policy: Setting[:default_non_yum_mirroring_policy],
          }
          root = product.add_repo(repo_params)
          plan_action(::Actions::Katello::Repository::CreateRoot, root)
        end

        def humanized_name
          _("Mirror Remote Repository")
        end
      end
    end
  end
end
