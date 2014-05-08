Foreman::Plugin.register :katello do
  requires_foreman '> 1.3'

  sub_menu :top_menu, :content_menu, :caption => N_('Content'), :after => :monitor_menu do
    menu :top_menu,
         :environments,
         :caption => N_('Lifecycle Environments'),
         :url => 'lifecycle_environments',
         :url_hash => {:controller => 'katello/api/v2/environments',
                       :action => 'index'},
         :engine => Katello::Engine
    menu :top_menu,
         :red_hat_subscriptions,
         :caption => N_('Red Hat Subscriptions'),
         :url => 'subscriptions',
         :url_hash => {:controller => 'katello/api/v2/subscriptions',
                       :action => 'index'},
         :engine => Katello::Engine
   # TODO
   # Refs http://projects.theforeman.org/issues/4883
   # menu :top_menu,
   #      :subscription_manager_applications,
   #      :caption => N_('Subscription Manager Applications'),
   #      :url_hash => {:controller => 'katello/distributors',
   #                    :action => 'index'},
   #      :engine => Katello::Engine
    menu :top_menu,
         :activation_keys,
         :url => 'activation_keys',
         :url_hash => {:controller => 'katello/api/v2/activation_keys',
                       :action => 'index'},
         :engine => Katello::Engine

    divider :top_menu, :parent => :content_menu
    menu :top_menu,
         :redhat_provider,
         :caption => N_('Red Hat Repositories'),
         :url_hash => {:controller => 'katello/providers',
                       :action => 'redhat_provider'},
         :engine => Katello::Engine

    menu :top_menu,
         :products,
         :caption => N_('Products'),
         :url => 'products',
         :url_hash => {:controller => 'katello/api/v2/products',
                       :action => 'index'},
         :engine => Katello::Engine

    menu :top_menu,
         :gpg_keys,
         :caption => N_('GPG keys'),
         :url => 'gpg_keys',
         :url_hash => {:controller => 'katello/api/v2/gpg_keys',
                       :action => 'index'},
         :engine => Katello::Engine

    divider :top_menu, :parent => :content_menu
    menu :top_menu,
         :sync_status,
         :caption => N_('Sync Status'),
         :url_hash => {:controller => 'katello/sync_management',
                       :action => 'index'},
         :engine => Katello::Engine

    menu :top_menu,
         :sync_plans,
         :caption => N_('Sync Plans'),
         :url => 'sync_plans',
         :url_hash => {:controller => 'katello/api/v2/sync_plans',
                       :action => 'index'},
         :engine => Katello::Engine

    divider :top_menu, :parent => :content_menu
    menu :top_menu,
         :content_views,
         :caption => N_('Content Views'),
         :url => 'content_views',
         :url_hash => {:controller => 'katello/api/v2/content_views',
                       :action => 'index'},
         :engine => Katello::Engine

    menu :top_menu,
         :content_search,
         :caption => N_('Content Search'),
         :url_hash => {:controller => 'katello/content_search',
                       :action => 'index'},
         :engine => Katello::Engine
  end

  menu :top_menu,
       :systems,
       :url => 'content_hosts',
       :url_hash => {:controller => 'katello/api/v2/content_hosts',
                     :action => 'index'},
       :engine => Katello::Engine,
       :parent => :hosts_menu,
       :after => :hosts

  menu :top_menu,
       :system_groups,
       :caption => N_('System Groups'),
       :url => 'system_groups',
       :url_hash => {:controller => 'katello/api/v2/system_groups',
                     :action => 'index'},
       :engine => Katello::Engine,
       :parent => :hosts_menu,
       :after => :systems

  menu :top_menu,
       :content_dashboard,
       :caption => N_('Content Dashboard'),
       :url_hash => {:controller => 'katello/dashboard',
                     :action => 'index'},
       :engine => Katello::Engine,
       :parent => :monitor_menu,
       :after => :dashboard

  menu :admin_menu,
       :notices,
       :caption => N_('Content Notices'),
       :url_hash => {:controller => 'katello/notices',
                     :action => 'show'},
       :engine => Katello::Engine,
       :parent => :administer_menu,
       :after => :organizations

  menu :admin_menu,
       :content_roles,
       :caption => N_('Content Roles'),
       :url_hash => {:controller => 'katello/roles',
                     :action => 'index'},
       :engine => Katello::Engine,
       :parent => :administer_menu,
       :after => :roles

  allowed_template_helpers :subscription_manager_configuration_url
end
