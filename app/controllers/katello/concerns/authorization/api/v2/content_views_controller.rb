module Katello
  module Concerns::Authorization::Api::V2::ContentViewsController
    extend ActiveSupport::Concern

    included do
      before_action :authorize_destroy, :only => [:destroy]
      before_action :authorize_remove_from_environment, :only => [:remove_from_environment]
      before_action :authorize_remove, :only => [:remove]
    end

    private

    def authorize_destroy
      view = find_content_view_for_authorization
      if view.deletable?
        true
      else
        deny_access
      end
    end

    def authorize_remove_from_environment
      view = find_content_view_for_authorization
      environment = find_environment_for_authorization
      if view.promotable_or_removable? && environment.promotable_or_removable?
        true
      else
        deny_access
      end
    end

    def authorize_remove
      view = find_content_view_for_authorization
      options = params.permit(:system_content_view_id,
                              :system_environment_id,
                              :key_content_view_id,
                              :key_environment_id,
                              :hostgroup_content_view_environment_id,
                              :content_view_version_ids => [],
                              :environment_ids => []
                             )
      options = options.reject { |_k, v| v.blank? }

      authorize_remove_versions(view, options) &&
        authorize_remove_environments(view, options) &&
        authorize_system_content_view(view, options) &&
        authorize_system_environments(view, options) &&
        authorize_activation_key_content_view(view, options) &&
        authorize_activation_key_environments(view, options) &&
        authorize_hostgroup_content_view_environment(view, options)
    end

    def authorize_remove_versions(view, options)
      return true if options[:content_view_version_ids].blank?

      # If we are deleting versions from the archives then we need content view delete.
      if view.deletable?
        true
      else
        deny_access
      end
    end

    def authorize_system_content_view(view, options)
      system_content_view_id = options[:system_content_view_id]
      if system_content_view_id
        sys_content_view = ContentView.where(:organization_id => view.organization,
                                             :id => system_content_view_id).first
        fail HttpErrors::NotFound, _("Couldn't find content host content view id '%s'") % system_content_view_id unless sys_content_view
        # deny if we cannot register systems to the new content view id
        return deny_access unless sys_content_view.readable?
      end
      true
    end

    def authorize_system_environments(view, options)
      system_environment_id = options[:system_environment_id]
      if system_environment_id
        sys_env = KTEnvironment.where(:organization_id => view.organization,
                                      :id => system_environment_id).first
        fail HttpErrors::NotFound, _("Couldn't find content host environment '%s'") % system_environment_id unless sys_env
        # deny if we cannot register systems to the new env id
        return deny_access unless sys_env.readable?
      end
      true
    end

    def authorize_activation_key_content_view(view, options)
      key_content_view_id = options[:key_content_view_id]
      if key_content_view_id
        key_content_view = ContentView.where(:organization_id => view.organization,
                                             :id => key_content_view_id).first
        fail HttpErrors::NotFound, _("Couldn't find activation key content view id '%s'") % key_content_view_id unless key_content_view
        # deny if we cannot reassign keys to the new content view id
        return deny_access unless key_content_view.readable?
      end
      true
    end

    def authorize_activation_key_environments(view, options)
      key_environment_id = options[:key_environment_id]
      if key_environment_id
        key_env = KTEnvironment.where(:organization_id => view.organization,
                                      :id => key_environment_id).first
        fail HttpErrors::NotFound, _("Couldn't find activation key environment '%s'") % key_environment_id unless key_env
        # deny if we cannot reassign keys to the new env id
        return deny_access unless key_env.readable?
      end
      true
    end

    def authorize_hostgroup_content_view_environment(view, options)
      cv_env_id = options[:hostgroup_content_view_environment_id]
      if cv_env_id
        cv_env = ContentViewEnvironment.joins(:content_view, :environment)
          .where(id: cv_env_id)
          .where("#{ContentView.table_name}.organization_id" => view.organization.id)
          .first
        fail HttpErrors::NotFound, _("Couldn't find host group content view environment id '%s'") % cv_env_id unless cv_env
        # deny if we cannot reassign hostgroups to the new content view environment
        return deny_access unless cv_env.content_view.readable? && cv_env.environment.readable?
      end
      true
    end

    def authorize_remove_environments(view, options)
      env_ids = options[:environment_ids]
      return true if env_ids.blank?
      return deny_access unless authorize_environment_removal_permissions(view, env_ids)

      authorize_host_reassignment(view, env_ids, options)
      authorize_activation_key_reassignment(view, env_ids, options)
      authorize_hostgroup_reassignment(view, env_ids, options)

      true
    end

    def authorize_environment_removal_permissions(view, env_ids)
      # Verify that all env_ids belong to the view
      return false unless (env_ids.map(&:to_s) - view.environment_ids.map(&:to_s)).empty?

      # Ensure the content view has remove permission and environments are promotable
      KTEnvironment.promotable.where(:id => env_ids).count == env_ids.size && view.promotable_or_removable?
    end

    def authorize_host_reassignment(view, env_ids, options)
      total_count = Katello::Host::ContentFacet.with_content_views(view).with_environments(env_ids).count
      single_env_host_count = Katello::Host::ContentFacet
        .with_content_views(view)
        .with_environments(env_ids)
        .count { |facet| !facet.multi_content_view_environment? }

      return unless single_env_host_count > 0

      unless options[:system_content_view_id] && options[:system_environment_id]
        fail _("Unable to reassign content hosts. Please provide system_content_view_id and system_environment_id.")
      end

      # Ensure all hosts in existing environments are editable
      authorized_count = ::Host::Managed.authorized('edit_hosts').in_content_view_environment(
        :content_view => view,
        :lifecycle_environment => ::Katello::KTEnvironment.where(:id => env_ids)
      ).count

      deny_access if total_count != authorized_count
    end

    def authorize_activation_key_reassignment(view, env_ids, options)
      keys = Katello::ActivationKey.with_content_views(view).with_environments(env_ids)
      single_env_keys_exist = keys.any? { |key| !key.multi_content_view_environment? }

      return unless single_env_keys_exist

      unless options[:key_content_view_id] && options[:key_environment_id]
        fail _("Unable to reassign activation_keys. Please provide key_content_view_id and key_environment_id.")
      end

      # Ensure all activation keys are editable
      return deny_access unless Katello::ActivationKey.all_editable?(view, env_ids)
    end

    def authorize_hostgroup_reassignment(view, env_ids, options)
      hostgroups = ::Hostgroup.joins(:content_facet => :content_view_environment)
        .where("#{::Katello::ContentViewEnvironment.table_name}.content_view_id" => view.id)
        .where("#{::Katello::ContentViewEnvironment.table_name}.environment_id" => env_ids)

      return unless hostgroups.any?

      unless options[:hostgroup_content_view_environment_id]
        fail _("Unable to reassign host groups. Please provide hostgroup_content_view_environment_id.")
      end

      # Ensure all hostgroups are editable
      return deny_access unless hostgroups.all? { |hg| hg.authorized?('edit_hostgroups') }
    end

    def find_content_view_for_authorization
      ContentView.find(params[:id])
    end

    def find_environment_for_authorization
      KTEnvironment.find(params[:environment_id])
    end
  end
end
