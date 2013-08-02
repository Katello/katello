#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
module Katello
  module Navigation
    module ContentMenu
      def self.included(base)
        base.class_eval do
          helper_method :content_view_definition_navigation
          helper_method :custom_provider_navigation
          helper_method :activation_keys_navigation
          helper_method :promotion_packages_navigation
          helper_method :promotion_errata_navigation
          helper_method :promotion_distribution_navigation
          helper_method :promotion_content_view_navigation
          helper_method :gpg_keys_navigation
          helper_method :subscriptions_navigation
          helper_method :new_subscription_navigation
          helper_method :distributors_navigation
          helper_method :new_distributor_navigation
        end
      end

      def content_view_definition_navigation
        [
          { :key => :view_definition_views,
            :name =>_("Views"),
            :url => (@view_definition.nil? || @view_definition.new_record?) ? "" : views_katello_content_view_definition_path(@view_definition.id),
            :if => lambda{!@view_definition.nil? && @view_definition.readable? && !@view_definition.new_record?},
            :options => {:class=>"panel_link"}
          },
          { :key => :view_definition_content,
            :name =>_("Content"),
            :url => (@view_definition.nil? || @view_definition.new_record?) ? "" : content_katello_content_view_definition_path(@view_definition.id),
            :if => lambda{!@view_definition.nil? && @view_definition.readable? && !@view_definition.new_record?},
            :options => {:class=>"panel_link"}
          },
          { :key => :view_definition_filter,
            :name =>_("Filters"),
            :url => (@view_definition.nil? || @view_definition.new_record?) ? "" : katello_content_view_definition_filters_path(@view_definition.id),
            :if => lambda{!@view_definition.nil? && @view_definition.readable? && !@view_definition.new_record? &&
                !@view_definition.composite},
            :options => {:class=>"panel_link"}
          },
          { :key => :view_definition_details,
            :name =>_("Details"),
            :url => (@view_definition.nil? || @view_definition.new_record?) ? "" : edit_katello_content_view_definition_path(@view_definition.id),
            :if => lambda{!@view_definition.nil? && @view_definition.readable? && !@view_definition.new_record?},
            :options => {:class=>"panel_link"}
          }
        ]
      end

      def custom_provider_navigation
        [
          { :key => :products_repos,
            :name =>_("Products & Repositories"),
            :url => (@provider.nil? || @provider.new_record?) ? "" : products_repos_katello_provider_path(@provider.id),
            :if => lambda{!@provider.nil? && @provider.readable? &&
                          !@provider.new_record? && !@provider.has_subscriptions?},
            :options => {:class=>"panel_link"}
          },
          { :key => :repo_discovery,
            :name =>_("Repository Discovery"),
            :url => (@provider.nil? || @provider.new_record?) ? "" : repo_discovery_katello_provider_path(@provider.id),
            :if => lambda{!@provider.nil? && @provider.editable? &&
                          !@provider.new_record?},
            :options => {:class=>"panel_link"}
          },
          { :key => :edit_custom_providers,
            :name =>_("Details"),
            :url => (@provider.nil? || @provider.new_record?) ? "" : edit_katello_provider_path(@provider.id),
            :if => lambda{!@provider.nil? && @provider.readable? && !@provider.new_record?},
            :options => {:class=>"panel_link"}
          }
        ]
      end

      def menu_subscriptions
        {:key => :subscriptions,
         :name =>_("Subscriptions"),
         :url => subscriptions_path,
         :items => lambda{[menu_subscriptions_list, menu_distributors_list, menu_activation_keys, menu_import_history]},
         :if => lambda{current_organization},
         :options => {:class=>'content second_level menu_parent', "data-menu"=>"content", "data-dropdown"=>"subscriptions"}
        }
      end

      def menu_subscriptions_list
        {:key => :red_hat_subscriptions,
         :name =>_("Red Hat Subscriptions"),
         :url => subscriptions_path,
         :if => lambda{current_organization.redhat_provider.readable?},
         :options => {:class=>'content third_level', "data-menu"=>"subscriptions", "data-dropdown"=>"subscriptions"}
        }
      end

      def menu_distributors_list
        {:key => :distributors_list,
         :name =>_("Subscription Management Applications"),
         :url => distributors_path,
         :if => lambda{current_organization && current_organization.readable?},
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
          :url => lambda {history_subscriptions_path},
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
            :items=> Katello.config.katello? ?
              [menu_subscriptions, menu_providers, menu_sync_management, menu_content_search,
               menu_content_view_definitions, menu_changeset_management] :
              [menu_subscriptions]
        }
      end

      def menu_providers
        {:key => :providers,
         :name =>_("Repositories"),
         :url => :sub_level,
         :if => :sub_level,
         :options => {:class=>'content second_level menu_parent', "data-menu"=>"content", "data-dropdown"=>"repositories"},
         :items => [menu_custom_providers, menu_redhat_providers, menu_gpg]
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
          :if => lambda{Katello.config.katello? && current_organization && Provider.any_readable?(current_organization())},
          :options => {:class=>"third_level", "data-dropdown"=>"repositories"}
        }
      end

      def menu_sync_management
        {:key => :sync_mgmt,
         :name =>_("Sync Management"),
         :items => lambda{[menu_sync_status, menu_sync_plan, menu_sync_schedule]},
         :if => lambda{Katello.config.katello? && (current_organization.syncable? || Provider.any_readable?(current_organization))},
         :options => {:class=>'content second_level menu_parent', "data-menu"=>"content", "data-dropdown"=>"sync"}
        }
      end

      def menu_content_search
        {:key => :content_search,
         :name =>_("Content Search"),
         :if => lambda{Katello.config.katello? && !KTEnvironment.content_readable(current_organization).empty?},
         :options => {:class=>'content second_level', "data-menu"=>"content"},
         :url =>content_search_index_path,
        }
      end

      def menu_content_view_definitions
        {:key => :content_view_definitions,
         :name => _("Content View Definitions"),
         :if => lambda{Katello.config.katello? && ContentViewDefinition.any_readable?(current_organization)},
         :options => {:class=>'content second_level', "data-menu"=>"content"},
         :url =>content_view_definitions_path,
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

      def menu_changeset_management
         {:key => :changeset_management,
          :name => _("Changeset Management"),
          :url => promotions_path,
          :items => lambda{[menu_changeset, menu_changeset_history]},
          :if => lambda {Katello.config.katello? && KTEnvironment.any_viewable_for_promotions?(current_organization)},
          :options => {:highlights_on =>/\/promotions.*/ , :class=>'menu_parent content second_level', "data-menu"=>"content", "data-dropdown"=>"changesets"}
         }
      end

      def menu_changeset
         {:key => :changesets,
          :name => _("Changesets"),
          :url => promotions_path,
          :if => lambda {Katello.config.katello? && KTEnvironment.any_viewable_for_promotions?(current_organization)},
          :options => {:highlights_on =>/\/promotions.*/ , :class=>'content third_level', "data-dropdown"=>"changesets"}
         }
      end

      def menu_changeset_history
         {:key => :changeset,
          :name => _("Changesets History"),
          :url => changesets_path,
          :if => lambda {Katello.config.katello? && KTEnvironment.any_viewable_for_promotions?(current_organization)},
          :options => {:class=>'content third_level', "data-dropdown"=>"changesets"}
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

      def promotion_packages_navigation
        [
          { :key => :dependencies,
            :name =>_("Dependencies"),
            :url => lambda{dependencies_package_path(@package.id)},
            :if => lambda{@package},
            :options => {:class=>"panel_link"}
          },
          { :key => :package_details,
            :name =>_("Details"),
            :url => lambda{package_path(@package.id)},
            :if => lambda{@package},
            :options => {:class=>"panel_link"}
          }
        ]
      end

      def promotion_errata_navigation
        [
          { :key => :errata_packages,
            :name =>_("Packages"),
            :url => lambda{packages_erratum_path(@errata.id)},
            :if => lambda{@errata},
            :options => {:class=>"panel_link"}
          },
          { :key => :errata_details,
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
          { :key => :distribution_details,
            :name =>_("Details"),
            :url => lambda{repository_distribution_path(@repo.id, URI::escape(@distribution.id))},
            :if => lambda{@distribution},
            :options => {:class=>"panel_link"}
          }
        ]
      end

      def promotion_content_view_navigation
        [
            { :key => :promotion_content_view_content,
              :name =>_("Content"),
              :url => lambda{content_organization_environment_content_view_version_path(@view_version.id)},
              :if => lambda{@view_version},
              :options => {:class=>"panel_link"}
            },
            { :key => :promotion_content_view_details,
              :name =>_("Details"),
              :url => lambda{organization_environment_content_view_version_path(@view_version.id)},
              :if => lambda{@view_version},
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
          { :key => :gpg_key_details,
            :name =>_("Details"),
            :url => lambda{edit_gpg_key_path(@gpg_key.id)},
            :if => lambda{@gpg_key},
            :options => {:class=>"panel_link"}
          }
        ]
      end

      def activation_keys_navigation
        menu = [
          { :key => :applied_subscriptions,
            :name =>_("Attached Subscriptions"),
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
          { :key => :activation_key_details,
            :name =>_("Details"),
            :url => lambda{edit_activation_key_path(@activation_key.id)},
            :if => lambda{@activation_key},
            :options => {:class=>"panel_link"}
          },
          { :key => :system_mgmt,
            :name =>_("System Groups"),
            :items => lambda{ak_systems_subnav},
            :if => lambda{@activation_key},
            :url => lambda{system_groups_activation_key_path(@activation_key.id)},
            :options => {:class=>'panel_link menu_parent'}
          }
        ]
        menu
      end

      def ak_systems_subnav
        [
          { :key => :activation_keys_menu_system_groups,
            :name =>_("System Groups"),
            :url => lambda{system_groups_activation_key_path(@activation_key.id)},
            :if => lambda{@activation_key},
            :options => {:class=>"third_level panel_link"}
          },
          { :key => :activation_keys_menu_systems,
            :name =>_("Systems"),
            :url => lambda{systems_activation_key_path(@activation_key.id)},
            :if => lambda{@activation_key},
            :options => {:class=>"third_level panel_link"}
          }
        ]
      end

      def subscriptions_navigation
        [
          { :key => :subscription_details,
            :name =>_("Details"),
            :url => lambda{edit_subscription_path(@subscription.cp_id)},
            :if => lambda{@subscription},
            :options => {:class=>"panel_link"},
          },
          { :key => :subscription_products,
            :name =>_("Products"),
            :url => lambda{products_subscription_path(@subscription.cp_id)},
            :if => lambda{@subscription},
            :options => {:class=>"panel_link"}
          },
          { :key => :consumers,
            :name =>_("Units"),
            :url => lambda{consumers_subscription_path(@subscription.cp_id)},
            :if => lambda{@subscription},
            :options => {:class=>"panel_link"}
          }
        ]
      end

      def new_subscription_navigation
        [
          { :key => :manifest_details,
            :name =>_("Details"),
            :url => edit_manifest_subscriptions_path,
            :if => lambda{current_organization && current_organization.readable?},
            :options => {:class=>"panel_link"},
          },
          { :key => :upload,
            :name =>_("Import"),
            :url => new_subscription_path,
            :if => lambda{current_organization && current_organization.readable?},
            :options => {:class=>"panel_link"},
          },
          { :key => :subscription_history,
            :name =>_("History"),
            :url => history_items_subscriptions_path,
            :if => lambda{current_organization && current_organization.readable?},
            :options => {:class=>"panel_link"}
          }
        ]
      end

      def distributors_navigation
        menu = [
          { :key => :distributor_details,
            :name =>_("Details"),
            :url => lambda{edit_distributor_path(@distributor.id)},
            :if => lambda{@distributor},
            :options => {:class=>"panel_link menu_parent"},
            :items => distributors_subnav
          },
          { :key => :distributor_subscriptions,
            :name =>_("Subscriptions"),
            :url => lambda{subscriptions_distributor_path(@distributor.id)},
            :if => lambda{@distributor},
            :options => {:class=>"panel_link"}
          }
        ]
        menu
      end

      def distributors_subnav
        [
          { :key => :distributor_info,
            :name =>_("Distributor Info"),
            :url => lambda{edit_distributor_path(@distributor.id)},
            :if => lambda{@distributor},
            :options => {:class=>"third_level panel_link"},
          },
          { :key => :distributor_events,
            :name =>_("Events History"),
            :url => lambda{distributor_events_path(@distributor.id)},
            :if => lambda{@distributor},
            :options => {:class=>"third_level panel_link"},
          },
          { :key => :custom_info,
            :name => _("Custom Information"),
            :url => lambda{custom_info_system_path(@distributor.id)},
            :if => lambda{@system},
            :options => {:class => "third_level panel_link"}
          },
          { :key => :custom_info,
            :name => _("Custom Information"),
            :url => lambda{custom_info_distributor_path(@distributor.id)},
            :if => lambda{@distributor},
            :options => {:class => "third_level panel_link"}
          }
        ]
      end


    end
  end
end
