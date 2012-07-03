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
        helper_method :system_groups_navigation
      end
    end
    def menu_systems
      menu = {:key => :systems,
       :name => _("Systems"),
        :url => :sub_level,
        :options => {:class=>'systems top_level', "data-menu"=>"systems"},
        :items=> [ menu_systems_org_list, menu_systems_environments_list]
      }
      menu[:items] << menu_system_groups if AppConfig.katello?
      menu
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
          :options => {:class=>"panel_link menu_parent"},
          :items => systems_subnav
        },
        { :key => :subscriptions,
          :name =>_("Subscriptions"),
          :url => lambda{subscriptions_system_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"panel_link"}
        },
        { :key => :content,
          :name =>_("Content"),
          :url => lambda{products_system_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"panel_link menu_parent"},
          :items => systems_content_subnav
        }
      ]
      a << { :key => :system_groups,
          :name =>_("System Groups"),
          :url => lambda{system_groups_system_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"panel_link"}
        } if AppConfig.katello?          
    end

    def systems_subnav
      [
        { :key => :system_info,
          :name =>_("System Info"),
          :url => lambda{edit_system_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"third_level panel_link"},
        },
        { :key => :events,
          :name =>_("Events History"),
          :url => lambda{system_events_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"third_level panel_link"},
        },
        { :key => :facts,
          :name =>_("Facts"),
          :url => lambda{facts_system_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"third_level panel_link"},
        }
      ]
    end

    def systems_content_subnav
      a = [
        { :key => :products,
          :name =>_("Software"),
          :url => lambda{products_system_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"third_level panel_link"}
        }
      ]
      a << { :key => :packages,
          :name =>_("Packages"),
          :url => lambda{packages_system_system_packages_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"third_level panel_link"}
        } if AppConfig.katello?
      a << { :key => :errata,
          :name =>_("Errata"),
          :url => lambda{system_errata_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"third_level panel_link"},
        } if AppConfig.katello?
    end

    def system_groups_navigation
      [
        {
          :key => :systems,
          :name => _('Systems'),
          :url => lambda{systems_system_group_path(@group.id)},
          :if => lambda{@group},
          :options => {:class=>"panel_link"}
        },
        { :key => :content,
          :name =>_("Content"),
          :url => lambda{system_group_packages_path(@group.id)},
          :if => lambda{@group},
          :options => {:class=>"panel_link menu_parent"},
          :items => system_groups_content_subnav
        },
        { :key => :details,
          :name =>_("Details"),
          :url => lambda{edit_system_group_path(@group.id)},
          :if => lambda{@group},
          :options => {:class=>"panel_link menu_parent"},
          :items => system_groups_subnav
        }
      ]
    end

    def system_groups_subnav
      [
        { :key => :system_group_info,
          :name =>_("System Group Info"),
          :url => lambda{edit_system_group_path(@group.id)},
          :if => lambda{@group},
          :options => {:class=>"third_level panel_link"},
        },
        { :key => :events,
          :name =>_("Events History"),
          :url => lambda{system_group_events_path(@group.id)},
          :if => lambda{@group},
          :options => {:class=>"third_level panel_link"}
        }
      ]
    end

    def system_groups_content_subnav
      [
        { :key => :packages,
          :name =>_("Packages"),
          :url => lambda{system_group_packages_path(@group.id)},
          :if => lambda{@group},
          :options => {:class=>"third_level panel_link"},
        },
        { :key => :errata,
          :name =>_("Errata"),
          :url => lambda{system_group_errata_path(@group.id)},
          :if => lambda{@group},
          :options => {:class=>"third_level panel_link"},
        }
      ]
    end

  end
end
