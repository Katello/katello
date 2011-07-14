# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|

  navigation.autogenerate_item_ids = false
  navigation.id_generator = Proc.new {|key| "kp-#{key}"}
  
  navigation.items do |top_level|
    top_level.item :dashboard, _("Dashboard"), {:controller => 'dashboard'}, :class=>'dashboard'  do |dashboard_sub|
      #TODO: tie in monitors page/link (if in dashboard page)
      dashboard_sub.item :monitors, _("Monitors"), '#', :class => 'disabled'
      #TODO: tie in reports page/link (if in dashboard page)
      dashboard_sub.item :reports, _("Reports"), '#', :class => 'disabled'
      #TODO: tie in notifications page/link (if in dashboard page)
      dashboard_sub.item :notifications, _("Notifications"), '#', :class => 'disabled'
      #TODO: tie in workflow page/link (if in dashboard page)
      dashboard_sub.item :workflow, _("Workflow"),  '#', :class => 'disabled'
    end #end dashboard_sub

    #top_level.item :content, _("Providers"),  {:controller => 'providers'}, :class=>'content', :highlights_on => /\/providers/ do |content_sub|
    #end

    top_level.item :content, _("Content Management"),  organization_providers_path(current_organization()), :class=>'content' do |content_sub|
      content_sub.item :providers, _("Providers"), organization_providers_path(current_organization()), :highlights_on => /(\/organizations\/.*\/providers)|(\/providers\/.*\/(products|repos))/ do |providers_sub|
        providers_sub.item :new, _("Create"), new_provider_path(),
                           :if => Proc.new { @provider.nil? || (!@provider.nil? && @provider.new_record?)},
                           :controller => 'providers'
        providers_sub.item :edit, _("Basics"), (@provider.nil? || @provider.new_record?) ? "" : edit_provider_path(@provider.id), :class => 'navigation_element',
                           :if => Proc.new { !@provider.nil? && !@provider.new_record? }
        providers_sub.item :subscriptions, _("Subscriptions"),(@provider.nil? || @provider.new_record?) ? "" : subscriptions_provider_path(@provider.id), :class => 'navigation_element',
                           :if => Proc.new { !@provider.nil? && !@provider.new_record? && @provider.has_subscriptions?}
        providers_sub.item :products_repos, _("Products & Repositories"),(@provider.nil? || @provider.new_record?) ? "" : products_repos_provider_path(@provider.id), :class => 'navigation_element',
                           :if => Proc.new { !@provider.nil? && !@provider.new_record? && !@provider.has_subscriptions?}
        # providers_sub.item :subscriptions, _("Schedule"), (@provider.nil? || @provider.new_record?) ? "" : schedule_provider_path(@provider.id), :class => 'disabled'
      end
      content_sub.item :sync_mgmt, _("Sync Management"), :controller => 'sync_management' do |sync_sub|
        sync_sub.item :status, _("Sync Status"), :controller => 'sync_management'
        sync_sub.item :plans, _("Sync Plans"), :controller => 'sync_plans'
        sync_sub.item :schedule, _("Sync Schedule"), :controller => 'sync_schedules'
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
      end
      content_sub.item :changeset, _("Changeset History"), :controller => 'changesets'
      content_sub.item :updates_bundle, _("Updates Bundle"), '#', :class => 'disabled', :if => Proc.new { false }

    end #end content
    
    #TODO: Add correct Systems subnav items
    top_level.item :systems, _("Systems"), {:controller => 'systems'}, :class=>'systems' do |systems_sub|
      #TODO: tie in Registration Page (if applicable)
      systems_sub.item :registered, _("Registered"), systems_path(), :controller =>"systems" do |system_sub|
        if !@system.nil?
          system_sub.item :general, _("General"), edit_system_path(@system.id), :class => "navigation_element", 
                                  :controller => "systems"
          system_sub.item :subscriptions, _("Subscriptions"), subscriptions_system_path(@system.id), :class => "navigation_element", 
                                  :controller => "systems"
                                  
          system_sub.item :facts, _("Facts"), facts_system_path(@system.id), :class => 'navigation_element',
                                  :controller => "systems"
                                                
          system_sub.item :packages, _("Packages"), packages_system_path(@system.id), :class => "navigation_element",
                                  :controller => "systems"
        else
          #render tri-nav when not 2pane request
          system_sub.item :all, _("All"), systems_path()
          system_sub.item :env, _("Environments"), environments_systems_path()
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
    end #end systems
    
    top_level.item :organizations, _("Organizations"), {:controller => 'organizations'}, :class=>'organizations' do |orgs_sub|
       orgs_sub.item :index, _("List"), organizations_path
       orgs_sub.item :subscriptions, _("Subscriptions"), subscriptions_path
    end #end organization 

    top_level.item :operations, _("Administration"), {:controller => 'operations'}, :class=>'operations' do |operations_sub|
      operations_sub.item :users, _("Users"), users_path do |user_sub|
        if !@user.nil?
          user_sub.item :general, _("General"), edit_user_path(@user.id), :class => "navigation_element", :controller => "users"
          user_sub.item :roles_and_permissions, _("Roles & Permissions"), edit_role_path(@user.own_role_id), :class => "navigation_element", :controller => "roles"
        end
      end
      operations_sub.item :roles, _("Roles"), roles_path
      operations_sub.item :proxies, _("Proxies"), '#', :class => 'disabled', :if => Proc.new { false }
    end #end operations

  end #end top_level

end #end navigation
