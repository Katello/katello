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
        helper_method :promotion_packages_navigation
        helper_method :promotion_errata_navigation
        helper_method :promotion_distribution_navigation
        helper_method :package_filter_navigation
      end
    end

    def custom_provider_navigation
      [
          { :key => :edit_custom_providers,
            :name =>N_("Basics"),
            :url => (@provider.nil? || @provider.new_record?) ? "" : edit_provider_path(@provider.id),
            :if => lambda{!@provider.nil? && @provider.readable? && !@provider.new_record?},
            :options => {:class=>"navigation_element"}
          },
          { :key => :products_repos,
            :name =>N_("Products & Repositories"),
            :url => (@provider.nil? || @provider.new_record?) ? "" : products_repos_provider_path(@provider.id),
            :if => lambda{!@provider.nil? && @provider.readable? &&
                          !@provider.new_record? && !@provider.has_subscriptions?},
            :options => {:class=>"navigation_element"}
          }
      ]
    end

    def menu_contents
      {:key => :content,
       :name => N_("Content Management"),
        :url => :sub_level,
        :options => {:class=>'content'},
        :if => lambda{current_organization},
        :items=> [ menu_providers, menu_sync_management, menu_system_templates, menu_promotions, menu_changeset]
      }
    end

    def menu_providers

      {:key => :providers,
       :name =>N_("Providers"),
       :url => :sub_level,
       :if => :sub_level,
       :items => [menu_custom_providers, menu_redhat_providers, menu_filters]
      }

    end

    def menu_redhat_providers
      {:key => :redhat_providers,
        :name =>N_("Red Hat"),
        :url => redhat_provider_providers_path,
        :if => lambda{current_organization && current_organization.readable?},
        :options => {:class=>"third_level"}
      }
    end

    def menu_custom_providers
      {:key => :custom_providers,
        :name =>N_("Custom"),
        :url => lambda{organization_providers_path(current_organization())},
        :if => lambda{current_organization && Provider.any_readable?(current_organization())},
        :options => {:class=>"third_level"}
      }
    end


    def menu_sync_management
      {:key => :sync_mgmt,
       :name =>N_("Sync Management"),
       :items => lambda{[menu_sync_status, menu_sync_plan, menu_sync_schedule]},
       :if => lambda{current_organization.syncable?},
      }

    end

    def menu_sync_status
      {:key => :sync_status,
        :name =>N_("Sync Status"),
        :url => sync_management_index_path(),
        :options => {:class=>"third_level"}
      }
    end


    def menu_sync_plan
      {:key => :sync_plans,
        :name =>N_("Sync Plans"),
        :url => sync_plans_path(),
        :options => {:class=>"third_level"}
      }
    end

    def menu_sync_schedule
      {:key => :sync_schedule,
        :name =>N_("Sync Schedule"),
        :url => sync_schedules_index_path(),
        :options => {:class=>"third_level"}
      }
    end

    def menu_system_templates
      {:key => :system_templates,
       :name =>N_("System Templates"),
        :url => system_templates_path,
        :if => lambda{SystemTemplate.any_readable?(current_organization())}
      }

    end



    def menu_promotions
       {:key => :promotions,
        :name => N_("Promotions"),
        :url => promotions_path,
        :options =>{:highlights_on =>/\/promotions.*/ ,:class => 'content'},
        :if => lambda {KTEnvironment.any_viewable_for_promotions?(current_organization)}
       }
    end

    def menu_changeset
       {:key => :changeset,
        :name => N_("Changeset History"),
        :url => changesets_path,
        :if => lambda {KTEnvironment.any_viewable_for_promotions?(current_organization)}
       }
    end


    def menu_filters
       {:key => :filters,
        :name => N_("Package Filters"),
        :url => filters_path,
        :if => lambda {Filter.any_readable?(current_organization)}
       }
    end


    def promotion_packages_navigation
      [
        { :key => :details,
          :name =>N_("Details"),
          :url => lambda{package_path(@package.id)},
          :if => lambda{@package},
          :options => {:class=>"navigation_element"}
        },
        { :key => :dependencies,
          :name =>N_("Dependencies"),
          :url => lambda{dependencies_package_path(@package.id)},
          :if => lambda{@package},
          :options => {:class=>"navigation_element"}
        },
        { :key => :changelog,
          :name =>N_("Changelog"),
          :url => lambda{changelog_package_path(@package.id)},
          :if => lambda{@package},
          :options => {:class=>"navigation_element"}
        },
        { :key => :filelist,
          :name =>N_("Filelist"),
          :url => lambda{filelist_package_path(@package.id)},
          :if => lambda{@package},
          :options => {:class=>"navigation_element"}
        }
      ]
    end

    def promotion_errata_navigation
      [
        { :key => :details,
          :name =>N_("Details"),
          :url => lambda{erratum_path(@errata.id)},
          :if => lambda{@errata},
          :options => {:class=>"navigation_element"}
        },
        { :key => :packages,
          :name =>N_("Packages"),
          :url => lambda{packages_erratum_path(@errata.id)},
          :if => lambda{@errata},
          :options => {:class=>"navigation_element"}
        }
      ]
    end

    def promotion_distribution_navigation
      [
        { :key => :details,
          :name =>N_("Details"),
          :url => lambda{distribution_path(@distribution.id)},
          :if => lambda{@distribution},
          :options => {:class=>"navigation_element"}
        },
        { :key => :filelist,
          :name =>N_("Filelist"),
          :url => lambda{filelist_distribution_path(@distribution.id)},
          :if => lambda{@distribution},
          :options => {:class=>"navigation_element"}
        }
      ]
    end


    def package_filter_navigation
      [
        { :key => :packages,
          :name =>N_("Filtered Packages"),
          :url => lambda{packages_filter_path(@filter.id)},
          :if => lambda{@filter},
          :options => {:class=>"navigation_element"}
        },
        { :key => :products,
          :name =>N_("Products and Repositories"),
          :url => lambda{products_filter_path(@filter.id)},
          :if => lambda{@filter},
          :options => {:class=>"navigation_element"}
        },
        { :key => :details,
          :name =>N_("Details"),
          :url => lambda{edit_filter_path(@filter.id)},
          :if => lambda{@filter},
          :options => {:class=>"navigation_element"}
        }
      ]
    end

  end
end