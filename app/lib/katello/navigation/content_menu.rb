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
        helper_method :content_view_navigation
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
        helper_method :custom_provider_navigation
      end
    end

    def content_view_navigation
      view_filter_check = lambda do
        !@view.nil? && @view.readable? && !@view.new_record? && !@view.composite
      end

      [
        { :key => :view_views,
          :name => _("Views"),
          :url => (@view.nil? || @view.new_record?) ? "" : views_content_view_path(@view.id),
          :if => lambda{!@view.nil? && @view.readable? && !@view.new_record?},
          :options => {:class => "panel_link"}
        },
        { :key => :view_content,
          :name => _("Content"),
          :url => (@view.nil? || @view.new_record?) ? "" : content_content_view_path(@view.id),
          :if => lambda{!@view.nil? && @view.readable? && !@view.new_record?},
          :options => {:class => "panel_link"}
        },
        { :key => :view_filter,
          :name => _("Filters"),
          :url => (@view.nil? || @view.new_record?) ? "" : content_view_filters_path(@view.id),
          :if => view_filter_check,
          :options => {:class => "panel_link"}
        },
        { :key => :view_details,
          :name => _("Details"),
          :url => (@view.nil? || @view.new_record?) ? "" : edit_content_view_path(@view.id),
          :if => lambda{!@view.nil? && @view.readable? && !@view.new_record?},
          :options => {:class => "panel_link"}
        }
      ]
    end

    def custom_provider_navigation
      product_repo_check = lambda do
        !@provider.nil? && @provider.readable? && !@provider.new_record? && !@provider.has_subscriptions?
      end

      [
        { :key => :products_repos,
          :name => _("Products & Repositories"),
          :url => (@provider.nil? || @provider.new_record?) ? "" : products_repos_provider_path(@provider.id),
          :if => product_repo_check,
          :options => {:class => "panel_link"}
        },
        { :key => :repo_discovery,
          :name => _("Repository Discovery"),
          :url => (@provider.nil? || @provider.new_record?) ? "" : repo_discovery_provider_path(@provider.id),
          :if => lambda{!@provider.nil? && @provider.editable? && !@provider.new_record?},
          :options => {:class => "panel_link"}
        },
        { :key => :edit_custom_providers,
          :name => _("Details"),
          :url => (@provider.nil? || @provider.new_record?) ? "" : edit_provider_path(@provider.id),
          :if => lambda{!@provider.nil? && @provider.readable? && !@provider.new_record?},
          :options => {:class => "panel_link"}
        }
      ]
    end

    def promotion_packages_navigation
      [
        { :key => :dependencies,
          :name => _("Dependencies"),
          :url => lambda{dependencies_package_path(@package.id)},
          :if => lambda{@package},
          :options => {:class => "panel_link"}
        },
        { :key => :package_details,
          :name => _("Details"),
          :url => lambda{package_path(@package.id)},
          :if => lambda{@package},
          :options => {:class => "panel_link"}
        }
      ]
    end

    def promotion_errata_navigation
      [
        { :key => :errata_packages,
          :name => _("Packages"),
          :url => lambda{packages_erratum_path(@errata.id)},
          :if => lambda{@errata},
          :options => {:class => "panel_link"}
        },
        { :key => :errata_details,
          :name => _("Details"),
          :url => lambda{erratum_path(@errata.id)},
          :if => lambda{@errata},
          :options => {:class => "panel_link"}
        }
      ]
    end

    def promotion_distribution_navigation
      [
        { :key => :filelist,
          :name => _("Filelist"),
          :url => lambda{filelist_repository_distribution_path(@repo.id, URI.escape(@distribution.id))},
          :if => lambda{@distribution},
          :options => {:class => "panel_link"}
        },
        { :key => :distribution_details,
          :name => _("Details"),
          :url => lambda{repository_distribution_path(@repo.id, URI.escape(@distribution.id))},
          :if => lambda{@distribution},
          :options => {:class => "panel_link"}
        }
      ]
    end

    def promotion_content_view_navigation
      [
          { :key => :promotion_content_view_content,
            :name => _("Content"),
            :url => lambda{content_organization_environment_content_view_version_path(@view_version.id)},
            :if => lambda{@view_version},
            :options => {:class => "panel_link"}
          },
          { :key => :promotion_content_view_details,
            :name => _("Details"),
            :url => lambda{organization_environment_content_view_version_path(@view_version.id)},
            :if => lambda{@view_version},
            :options => {:class => "panel_link"}
          }
      ]
    end

    def gpg_keys_navigation
      [
        { :key => :products_repositories,
          :name => _("Products and Repositories"),
          :url => lambda{products_repos_gpg_key_path(@gpg_key.id)},
          :if => lambda{@gpg_key},
          :options => {:class => "panel_link"}
        },
        { :key => :gpg_key_details,
          :name => _("Details"),
          :url => lambda{edit_gpg_key_path(@gpg_key.id)},
          :if => lambda{@gpg_key},
          :options => {:class => "panel_link"}
        }
      ]
    end

    def activation_keys_navigation
      menu = [
        { :key => :applied_subscriptions,
          :name => _("Attached Subscriptions"),
          :url => lambda{applied_subscriptions_activation_key_path(@activation_key.id)},
          :if => lambda{@activation_key},
          :options => {:class => "panel_link"}
        },
        { :key => :available_subscriptions,
          :name => _("Available Subscriptions"),
          :url => lambda{available_subscriptions_activation_key_path(@activation_key.id)},
          :if => lambda{@activation_key},
          :options => {:class => "panel_link"}
        },
        { :key => :activation_key_details,
          :name => _("Details"),
          :url => lambda{edit_activation_key_path(@activation_key.id)},
          :if => lambda{@activation_key},
          :options => {:class => "panel_link"}
        },
        { :key => :system_mgmt,
          :name => _("System Groups"),
          :items => lambda{ak_systems_subnav},
          :if => lambda{@activation_key},
          :url => lambda{system_groups_activation_key_path(@activation_key.id)},
          :options => {:class => 'panel_link menu_parent'}
        }
      ]
      menu
    end

    def ak_systems_subnav
      [
        { :key => :activation_keys_menu_system_groups,
          :name => _("System Groups"),
          :url => lambda{system_groups_activation_key_path(@activation_key.id)},
          :if => lambda{@activation_key},
          :options => {:class => "third_level panel_link"}
        },
        { :key => :activation_keys_menu_systems,
          :name => _("Systems"),
          :url => lambda{systems_activation_key_path(@activation_key.id)},
          :if => lambda{@activation_key},
          :options => {:class => "third_level panel_link"}
        }
      ]
    end

    def subscriptions_navigation
      [
        { :key => :subscription_details,
          :name => _("Details"),
          :url => lambda{edit_subscription_path(@subscription.cp_id)},
          :if => lambda{@subscription},
          :options => {:class => "panel_link"},
        },
        { :key => :subscription_products,
          :name => _("Products"),
          :url => lambda{products_subscription_path(@subscription.cp_id)},
          :if => lambda{@subscription},
          :options => {:class => "panel_link"}
        },
        { :key => :consumers,
          :name => _("Units"),
          :url => lambda{consumers_subscription_path(@subscription.cp_id)},
          :if => lambda{@subscription},
          :options => {:class => "panel_link"}
        }
      ]
    end

    def new_subscription_navigation
      [
        { :key => :manifest_details,
          :name => _("Details"),
          :url => edit_manifest_subscriptions_path,
          :if => lambda{current_organization && current_organization.readable?},
          :options => {:class => "panel_link"},
        },
        { :key => :upload,
          :name => _("Import"),
          :url => new_subscription_path,
          :if => lambda{current_organization && current_organization.readable?},
          :options => {:class => "panel_link"},
        },
        { :key => :subscription_history,
          :name => _("History"),
          :url => history_items_subscriptions_path,
          :if => lambda{current_organization && current_organization.readable?},
          :options => {:class => "panel_link"}
        }
      ]
    end

    def distributors_navigation
      menu = [
        { :key => :distributor_details,
          :name => _("Details"),
          :url => lambda{edit_distributor_path(@distributor.id)},
          :if => lambda{@distributor},
          :options => {:class => "panel_link menu_parent"},
          :items => distributors_subnav
        },
        { :key => :distributor_subscriptions,
          :name => _("Subscriptions"),
          :url => lambda{subscriptions_distributor_path(@distributor.id)},
          :if => lambda{@distributor},
          :options => {:class => "panel_link"}
        }
      ]
      menu
    end

    def distributors_subnav
      [
        { :key => :distributor_info,
          :name => _("Distributor Info"),
          :url => lambda{edit_distributor_path(@distributor.id)},
          :if => lambda{@distributor},
          :options => {:class => "third_level panel_link"},
        },
        { :key => :distributor_events,
          :name => _("Events History"),
          :url => lambda{distributor_events_path(@distributor.id)},
          :if => lambda{@distributor},
          :options => {:class => "third_level panel_link"},
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
