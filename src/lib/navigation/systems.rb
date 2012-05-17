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
  module SystemMenu
    def self.included(base)
      base.class_eval do
        helper_method :systems_navigation
        helper_method :activation_keys_navigation
        helper_method :system_groups_navigation
      end
    end
    def menu_systems
      {:key => :systems,
       :name => _("Systems"),
        :url => :sub_level,
        :options => {:class=>'systems top_level', "data-menu"=>"systems"},
        :items=> [ menu_systems_org_list, menu_systems_environments_list, menu_system_groups, menu_activation_keys]
      }
    end

    def menu_systems_org_list
      {:key => :registered,
       :name => _("All"),
       :url => systems_path,
       :if => lambda{current_organization && System.any_readable?(current_organization)},
       :options => {:class=>'systems second_level', "data-menu"=>"systems"}
      }
    end

    def menu_systems_environments_list
      {:key => :env,
       :name => _("By Environments"),
       :url => environments_systems_path(),
       :if => lambda{current_organization && System.any_readable?(current_organization)},
       :options => {:class=>'systems second_level', "data-menu"=>"systems"}
      }
    end

    def menu_activation_keys
       {:key => :activation_keys,
        :name => _("Activation Keys"),
        :url => activation_keys_path,
        :if => lambda {current_organization && ActivationKey.readable?(current_organization())},
        :options => {:class=>'systems second_level', "data-menu"=>"systems"}
       }
    end

    def menu_system_groups
       {:key => :system_groups,
        :name => _("System Groups"),
        :url => system_groups_path,
        :if => lambda {current_organization && SystemGroup.any_readable?(current_organization())},
        :options => {:class=>'systems second_level', "data-menu"=>"systems"}
       }
    end

    def systems_navigation
      a = [
        { :key => :general,
          :name =>_("Details"),
          :url => lambda{edit_system_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"navigation_element"},
          :items => systems_subnav
        },
        { :key => :subscriptions,
          :name =>_("Subscriptions"),
          :url => lambda{subscriptions_system_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"navigation_element"}
        },
        { :key => :content,
          :name =>_("Content"),
          :url => lambda{products_system_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"navigation_element"},
          :items => systems_content_subnav
        }
      ]
      a << { :key => :system_groups,
          :name =>_("System Groups"),
          :url => lambda{system_groups_system_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"navigation_element"}
        } if AppConfig.katello?          
      a << { :key => :packages,
          :name =>_("Packages"),
          :url => lambda{packages_system_system_packages_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"navigation_element"}
        } if AppConfig.katello?
      a << { :key => :errata,
          :name =>_("Errata"),
          :url => lambda{system_errata_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"navigation_element"},
        } if AppConfig.katello?
      a
    end

    def systems_subnav
      [
        { :key => :system_info,
          :name =>_("System Info"),
          :url => lambda{edit_system_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"third_level navigation_element"},
        },
        { :key => :events,
          :name =>_("Events"),
          :url => lambda{system_events_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"third_level navigation_element"},
        },
        { :key => :facts,
          :name =>_("Facts"),
          :url => lambda{facts_system_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"third_level navigation_element"},
        }
      ]
    end

    def systems_content_subnav
      [
        { :key => :products,
          :name =>_("Software"),
          :url => lambda{products_system_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"third_level navigation_element"}
        },
        { :key => :packages,
          :name =>_("Packages"),
          :url => lambda{packages_system_system_packages_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"third_level navigation_element"}
        },
        { :key => :errata,
          :name =>_("Errata"),
          :url => lambda{system_errata_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"third_level navigation_element"},
        }
      ]
    end

    def system_groups_navigation
      [
        {
          :key => :systems,
          :name => _('Systems'),
          :url => lambda{systems_system_group_path(@group.id)},
          :if => lambda{@group},
          :options => {:class=>"navigation_element"}
        },
#        { :key => :content,
#          :name =>_("Content"),
#          :url => lambda{system_group_errata_path(@group.id)},
#          :if => lambda{@group},
#          :options => {:class=>"navigation_element"},
#          :items => system_groups_content_subnav
#        },
        { :key => :errata,
          :name =>_("Errata"),
          :url => lambda{system_group_errata_path(@group.id)},
          :if => lambda{@group},
          :options => {:class=>"navigation_element"},
        },
        { :key => :details,
          :name =>_("Details"),
          :url => lambda{edit_system_group_path(@group.id)},
          :if => lambda{@group},
          :options => {:class=>"navigation_element"}
        }
      ]
    end

    def system_groups_content_subnav
      [
#        { :key => :packages,
#          :name =>_("Packages"),
#          :url => lambda{packages_system_system_packages_path(@system.id)},
#          :if => lambda{@system},
#          :options => {:class=>"third_level navigation_element"}
#        },
        { :key => :errata,
          :name =>_("Errata"),
          :url => lambda{system_group_errata_path(@group.id)},
          :if => lambda{@group},
          :options => {:class=>"third_level navigation_element"},
        }
      ]
    end

    def activation_keys_navigation
      [
        { :key => :applied_subscriptions,
          :name =>_("Applied Subscriptions"),
          :url => lambda{applied_subscriptions_activation_key_path(@activation_key.id)},
          :if =>lambda{@activation_key},
          :options => {:class=>"navigation_element"}
        },
        { :key => :available_subscriptions,
          :name =>_("Available Subscriptions"),
          :url => lambda{available_subscriptions_activation_key_path(@activation_key.id)},
          :if => lambda{@activation_key},
          :options => {:class=>"navigation_element"}
        },
        { :key => :system_groups,
          :name =>_("System Groups"),
          :url => lambda{system_groups_activation_key_path(@activation_key.id)},
          :if => lambda{@activation_key},
          :options => {:class=>"navigation_element"}
        },
        { :key => :details,
          :name =>_("Details"),
          :url => lambda{edit_activation_key_path(@activation_key.id)},
          :if => lambda{@activation_key},
          :options => {:class=>"navigation_element"}
        }
      ]
    end

  end
end
