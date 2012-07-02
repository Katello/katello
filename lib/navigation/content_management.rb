#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
module Navigation
  module ContentMenu
    def self.included(base)
      base.class_eval do
        helper_method :custom_provider_navigation
        helper_method :activation_keys_navigation
        helper_method :promotion_packages_navigation
        helper_method :promotion_errata_navigation
        helper_method :promotion_distribution_navigation
        helper_method :package_filter_navigation
        helper_method :gpg_keys_navigation
      end
    end

    def custom_provider_navigation
      [
        { :key => :products_repos,
          :name =>_("Products & Repositories"),
          :url => (@provider.nil? || @provider.new_record?) ? "" : products_repos_provider_path(@provider.id),
          :if => lambda{!@provider.nil? && @provider.readable? &&
                        !@provider.new_record? && !@provider.has_subscriptions?},
          :options => {:class=>"panel_link"}
        },
        { :key => :edit_custom_providers,
          :name =>_("Details"),
          :url => (@provider.nil? || @provider.new_record?) ? "" : edit_provider_path(@provider.id),
          :if => lambda{!@provider.nil? && @provider.readable? && !@provider.new_record?},
          :options => {:class=>"panel_link"}
        }
      ]
    end

    def menu_subscriptions
      {:key => :subscriptions,
       :name =>_("Subscriptions"),
       :url => subscriptions_path,
       :items => lambda{[menu_activation_keys, menu_import_history]},
       :if => lambda{current_organization},
       :options => {:class=>'content second_level menu_parent', "data-menu"=>"content", "data-dropdown"=>"subscriptions"}
      }
    end

    def menu_subscriptions_list
      {:key => :subscriptions,
       :name =>_("Red Hat Subscriptions"),
       :url => subscriptions_path,
       :if => lambda{current_organization},
       :options => {:class=>'content third_level', "data-menu"=>"subscriptions", "data-dropdown"=>"subscriptions"}
      }
    end

    def menu_activation_keys
      {
        :key => :activation_keys,
        :name => _("Activation Keys"),
        :url => activation_keys_path,
        :if => lambda {current_organization && ActivationKey.readable?(current_organization())},
        :options => {:class=>'content third_level', "data-menu"=>"subscriptions", "data-dropdown"=>"subscriptions"}
      }
    end

    def menu_import_history
      {
        :key => :import_history,
        :name => _("Import History"),
        :url => redhat_provider_providers_path,
        :if => lambda{current_organization && current_organization.readable?},
        :options => {:class=>'content third_level', "data-menu"=>"subscriptions", "data-dropdown"=>"subscriptions"}
      }
    end

    def menu_contents
      {:key => :content,
       :name => _("Content"),
        :url => :sub_level,
        :options => {:class=>'content top_level', "data-menu"=>"content"},
        :if => lambda{current_organization},
        :items=> [ menu_subscriptions, menu_providers, menu_sync_management, menu_system_templates, menu_promotions]
      }
    end

    def menu_providers
      {:key => :providers,
       :name =>_("Repositories"),
       :url => :sub_level,
       :if => :sub_level,
       :options => {:class=>'content second_level menu_parent', "data-menu"=>"content", "data-dropdown"=>"repositories"},
       :items => AppConfig.katello? ? [menu_custom_providers, menu_redhat_providers, menu_filters, menu_gpg] : [menu_custom_providers, menu_redhat_providers]
      }

    end

    def menu_redhat_providers
      {:key => :redhat_providers,
        :name =>_("Red Hat Repositories"),
        :url => redhat_provider_providers_path,
        :if => lambda{current_organization && current_organization.readable?},
        :options => {:class=>"third_level", "data-dropdown"=>"repositories"}
      }
    end

    def menu_custom_providers
      {:key => :custom_providers,
        :name =>_("Custom Content Repositories"),
        :url => providers_path,
        :if => lambda{AppConfig.katello? && current_organization && Provider.any_readable?(current_organization())},
        :options => {:class=>"third_level", "data-dropdown"=>"repositories"}
      }
    end

    def menu_sync_management
      {:key => :sync_mgmt,
       :name =>_("Sync Management"),
       :items => lambda{[menu_sync_status, menu_sync_plan, menu_sync_schedule]},
       :if => lambda{AppConfig.katello? && (current_organization.syncable? || Provider.any_readable?(current_organization))},
       :options => {:class=>'content second_level menu_parent', "data-menu"=>"content", "data-dropdown"=>"sync"}
      }
    end

    def menu_sync_status
      {:key => :sync_status,
        :name =>_("Sync Status"),
        :url => sync_management_index_path(),
        :options => {:class=>"third_level", "data-dropdown"=>"sync"}
      }
    end


    def menu_sync_plan
      {:key => :sync_plans,
        :name =>_("Sync Plans"),
        :url => sync_plans_path(),
        :options => {:class=>"third_level", "data-dropdown"=>"sync"}
      }
    end

    def menu_sync_schedule
      {:key => :sync_schedule,
        :name =>_("Sync Schedule"),
        :url => sync_schedules_index_path(),
        :options => {:class=>"third_level", "data-dropdown"=>"sync"}
      }
    end

    def menu_system_templates
      {:key => :system_templates,
       :name =>_("System Templates"),
        :url => system_templates_path,
        :if => lambda{AppConfig.katello? && SystemTemplate.any_readable?(current_organization())},
        :options => {:class=>'content second_level', "data-menu"=>"content"}
      }

    end

    def menu_promotions
       {:key => :changeset_promotions,
        :name => _("Changeset Promotions"),
        :url => promotions_path,
        :items => lambda{[menu_promotions_list, menu_changeset]},
        :if => lambda {AppConfig.katello? && KTEnvironment.any_viewable_for_promotions?(current_organization)},
        :options => {:highlights_on =>/\/promotions.*/ , :class=>'menu_parent content second_level', "data-menu"=>"content", "data-dropdown"=>"promotions"}
       }
    end

    def menu_promotions_list
       {:key => :promotions,
        :name => _("Promotions"),
        :url => promotions_path,
        :if => lambda {AppConfig.katello? && KTEnvironment.any_viewable_for_promotions?(current_organization)},
        :options => {:highlights_on =>/\/promotions.*/ , :class=>'content third_level', "data-dropdown"=>"promotions"}
       }
    end

    def menu_changeset
       {:key => :changeset,
        :name => _("Changeset Promotion History"),
        :url => changesets_path,
        :if => lambda {AppConfig.katello? && KTEnvironment.any_viewable_for_promotions?(current_organization)},
        :options => {:class=>'content third_level', "data-dropdown"=>"promotions"}
       }
    end

    def menu_gpg
       {:key => :gpg,
        :name => _("GPG Keys"),
        :url => gpg_keys_path,
        :if => lambda {GpgKey.any_readable?(current_organization)},
        :options => {:class=>"third_level", "data-dropdown"=>"repositories"}
       }
    end

    def menu_filters
       {:key => :filters,
        :name => _("Package Filters"),
        :url => filters_path,
        :if => lambda {Filter.any_readable?(current_organization)},
        :options => {:class=>"third_level", "data-dropdown"=>"repositories"}
       }
    end

    def promotion_packages_navigation
      [
        { :key => :dependencies,
          :name =>_("Dependencies"),
          :url => lambda{dependencies_package_path(@package.id)},
          :if => lambda{@package},
          :options => {:class=>"panel_link"}
        },
        { :key => :details,
          :name =>_("Details"),
          :url => lambda{package_path(@package.id)},
          :if => lambda{@package},
          :options => {:class=>"panel_link"}
        }
      ]
    end

    def promotion_errata_navigation
      [
        { :key => :packages,
          :name =>_("Packages"),
          :url => lambda{packages_erratum_path(@errata.id)},
          :if => lambda{@errata},
          :options => {:class=>"panel_link"}
        },
        { :key => :details,
          :name =>_("Details"),
          :url => lambda{erratum_path(@errata.id)},
          :if => lambda{@errata},
          :options => {:class=>"panel_link"}
        }
      ]
    end

    def promotion_distribution_navigation
      [
        { :key => :filelist,
          :name =>_("Filelist"),
          :url => lambda{filelist_repository_distribution_path(@repo.id, URI::escape(@distribution.id))},
          :if => lambda{@distribution},
          :options => {:class=>"panel_link"}
        },
        { :key => :details,
          :name =>_("Details"),
          :url => lambda{repository_distribution_path(@repo.id, URI::escape(@distribution.id))},
          :if => lambda{@distribution},
          :options => {:class=>"panel_link"}
        }
      ]
    end

    def package_filter_navigation
      [
        { :key => :packages,
          :name =>_("Filtered Packages"),
          :url => lambda{packages_filter_path(@filter.id)},
          :if => lambda{@filter},
          :options => {:class=>"panel_link"}
        },
        { :key => :products,
          :name =>_("Products and Repositories"),
          :url => lambda{products_filter_path(@filter.id)},
          :if => lambda{@filter},
          :options => {:class=>"panel_link"}
        },
        { :key => :details,
          :name =>_("Details"),
          :url => lambda{edit_filter_path(@filter.id)},
          :if => lambda{@filter},
          :options => {:class=>"panel_link"}
        }
      ]
    end
    
    def gpg_keys_navigation
      [
        { :key => :products_repositories,
          :name =>_("Products and Repositories"),
          :url => lambda{products_repos_gpg_key_path(@gpg_key.id)},
          :if =>lambda{@gpg_key},
          :options => {:class=>"panel_link"}
        },
        { :key => :details,
          :name =>_("Details"),
          :url => lambda{edit_gpg_key_path(@gpg_key.id)},
          :if => lambda{@gpg_key},
          :options => {:class=>"panel_link"}
        }
      ]
    end

    def activation_keys_navigation
      [
        { :key => :applied_subscriptions,
          :name =>_("Applied Subscriptions"),
          :url => lambda{applied_subscriptions_activation_key_path(@activation_key.id)},
          :if =>lambda{@activation_key},
          :options => {:class=>"panel_link"}
        },
        { :key => :available_subscriptions,
          :name =>_("Available Subscriptions"),
          :url => lambda{available_subscriptions_activation_key_path(@activation_key.id)},
          :if => lambda{@activation_key},
          :options => {:class=>"panel_link"}
        },
        { :key => :system_groups,
          :name =>_("System Groups"),
          :url => lambda{system_groups_activation_key_path(@activation_key.id)},
          :if => lambda{@activation_key},
          :options => {:class=>"panel_link"}
        },
        { :key => :details,
          :name =>_("Details"),
          :url => lambda{edit_activation_key_path(@activation_key.id)},
          :if => lambda{@activation_key},
          :options => {:class=>"panel_link"}
        }
      ]
    end

  end
end
