# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|

  navigation.autogenerate_item_ids = false
  navigation.id_generator = Proc.new {|key| "kp-#{key}"}
  
  navigation.items do |top_level|
    top_level.item :dashboard, _("Dashboard"), dashboard_index_path(), :class=>'dashboard'  do |dashboard_sub|
      #TODO: tie in monitors page/link (if in dashboard page)
      #dashboard_sub.item :monitors, _("Monitors"), '#', :class => 'disabled'
      #TODO: tie in reports page/link (if in dashboard page)
      #dashboard_sub.item :reports, _("Reports"), '#', :class => 'disabled'
      #TODO: tie in notifications page/link (if in dashboard page)
      #dashboard_sub.item :notifications, _("Notifications"), '#', :class => 'disabled'
      #TODO: tie in workflow page/link (if in dashboard page)
      #dashboard_sub.item :workflow, _("Workflow"),  '#', :class => 'disabled'
    end #end dashboard_sub


    top_level.item :content, _("Content Management"),  organization_providers_path(current_organization()), :class=>'content' do |content_sub|
      content_sub.item :providers, _("Providers"), organization_providers_path(current_organization()), :highlights_on => /(\/organizations\/.*\/providers)|(\/providers\/.*\/(products|repos))/ do |providers_sub|
        providers_sub.item :edit, _("Basics"), (@provider.nil? || @provider.new_record?) ? "" : edit_provider_path(@provider.id), :class => 'navigation_element',
                           :if => Proc.new { !@provider.nil? && !@provider.new_record? }
        providers_sub.item :subscriptions, _("Subscriptions"),(@provider.nil? || @provider.new_record?) ? "" : subscriptions_provider_path(@provider.id), :class => 'navigation_element',
                           :if => Proc.new { !@provider.nil? && !@provider.new_record? && @provider.has_subscriptions?}
        providers_sub.item :products_repos, _("Products & Repositories"),(@provider.nil? || @provider.new_record?) ? "" : products_repos_provider_path(@provider.id), :class => 'navigation_element',
                           :if => Proc.new { !@provider.nil? && !@provider.new_record? && !@provider.has_subscriptions?}
        # providers_sub.item :subscriptions, _("Schedule"), (@provider.nil? || @provider.new_record?) ? "" : schedule_provider_path(@provider.id), :class => 'disabled'
      end
      content_sub.item :sync_mgmt, _("Sync Management"), sync_management_index_path() do |sync_sub|
        sync_sub.item :status, _("Sync Status"), sync_management_index_path()
        sync_sub.item :plans, _("Sync Plans"), sync_plans_path()
        sync_sub.item :schedule, _("Sync Schedule"), sync_schedules_index_path()
      end
      #TODO: tie in Content Locker page
      content_sub.item :promotions, _("Promotions"), promotions_path(current_organization().name, current_organization().locker.name), :highlights_on =>/\/organizations\/.*\/environments\/.*\/promotions/ ,:class => 'content' do |package_sub|
          if !@package.nil?
              package_sub.item :details, _("Details"), package_path(@package.id), :class=>"navigation_element"
              package_sub.item :details, _("Dependencies"), dependencies_package_path(@package.id), :class=>"navigation_element"
              package_sub.item :details, _("Changelog"), changelog_package_path(@package.id), :class=>"navigation_element"
              package_sub.item :details, _("Filelist"), filelist_package_path(@package.id), :class=>"navigation_element"
          end
          if !@errata.nil?
              package_sub.item :details, _("Details"),  erratum_path(@errata.id), :class=>"navigation_element"
              package_sub.item :details, _("Packages"),  packages_erratum_path(@errata.id), :class=>"navigation_element"
          end
          if !@distribution.nil?
              package_sub.item :details, _("Details"), distribution_path(@distribution.id), :class=>"navigation_element"
              package_sub.item :details, _("Filelist"), filelist_distribution_path(@distribution.id), :class=>"navigation_element"
          end
      end
      content_sub.item :changeset, _("Changeset History"), changesets_path()
      #content_sub.item :updates_bundle, _("Updates Bundle"), '#', :class => 'disabled', :if => Proc.new { false }

    end if current_organization() #end content

    #TODO: Add correct Systems subnav items
    top_level.item :systems, _("Systems"), systems_path(), :class=>'systems' do |systems_sub|
      #TODO: tie in Registration Page (if applicable)
      systems_sub.item :registered, _("All"), systems_path() do |system_sub|
        if !@system.nil?
          system_sub.item :general, _("General"), edit_system_path(@system.id), :class => "navigation_element"
          system_sub.item :subscriptions, _("Subscriptions"), subscriptions_system_path(@system.id), :class => "navigation_element"
          system_sub.item :facts, _("Facts"), facts_system_path(@system.id), :class => 'navigation_element'
          system_sub.item :packages, _("Packages"), packages_system_path(@system.id), :class => "navigation_element"
        end
      end
      systems_sub.item :env, _("By Environments"), environments_systems_path() do |env_system_sub|
        if !@system.nil?
          env_system_sub.item :general, _("General"), edit_system_path(@system.id), :class => "navigation_element"
          env_system_sub.item :subscriptions, _("Subscriptions"), subscriptions_system_path(@system.id), :class => "navigation_element"
          env_system_sub.item :facts, _("Facts"), facts_system_path(@system.id), :class => 'navigation_element'
          env_system_sub.item :packages, _("Packages"), packages_system_path(@system.id), :class => "navigation_element"
        end
      end
      systems_sub.item :activation_keys, _("Activation Keys"), activation_keys_path do |activation_key_sub|
        if !@activation_key.nil?
          activation_key_sub.item :general, _("General"), edit_activation_key_path(@activation_key.id), :class => "navigation_element", 
                                  :controller => "activation_keys"
          activation_key_sub.item :subscriptions, _("Subscriptions"), subscriptions_activation_key_path(@activation_key.id), :class => "navigation_element", 
                                  :controller => "activation_keys"
        end
      end
    end if current_organization() #end systems

    top_level.item :organizations, _("Organizations"), organizations_path(), :class=>'organizations' do |orgs_sub|
       orgs_sub.item :index, _("List"), organizations_path()
       orgs_sub.item :subscriptions, _("Subscriptions"), subscriptions_path()
    end if current_organization()  #end organization

    top_level.item :operations, _("Administration"), operations_path(), :class=>'operations' do |operations_sub|
      operations_sub.item :users, _("Users"), users_path do |user_sub|
        if !@user.nil?
          user_sub.item :general, _("General"), edit_user_path(@user.id), :class => "navigation_element"
          user_sub.item :roles_and_permissions, _("Roles & Permissions"), edit_role_path(@user.own_role_id), :class => "navigation_element"
        end
      end
      operations_sub.item :roles, _("Roles"), roles_path
      #operations_sub.item :proxies, _("Proxies"), '#', :class => 'disabled', :if => Proc.new { false }
    end #end operations

  end #end top_level

end #end navigation
