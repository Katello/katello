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
      end
    end
    def menu_systems
      {:key => :systems,
       :name => N_("Systems"),
        :url => :sub_level,
        :options => {:class=>'systems'},
        :if => lambda{current_organization && System.any_readable?(current_organization)},
        :items=> [ menu_systems_org_list, menu_systems_environments_list]
      }
    end


    def menu_systems_org_list
      {:key => :registered,
       :name => N_("All"),
       :url => systems_path,

      }
    end

    def menu_systems_environments_list
      {:key => :env,
       :name => N_("By Environments"),
       :url => environments_systems_path()
      }
    end

    def systems_navigation
      [
        { :key => :general,
          :name =>N_("General"),
          :url => lambda{edit_system_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"navigation_element"}
        },
        { :key => :subscriptions,
          :name =>N_("Subscriptions"),
          :url => lambda{subscriptions_system_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"navigation_element"}
        },
        { :key => :facts,
          :name =>N_("Facts"),
          :url => lambda{facts_system_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"navigation_element"}
        },
        { :key => :packages,
          :name =>N_("Packages"),
          :url => lambda{packages_system_path(@system.id)},
          :if => lambda{@system},
          :options => {:class=>"navigation_element"}
        }
      ]
    end

  end
end