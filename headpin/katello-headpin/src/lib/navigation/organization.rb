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
  module OrganizationMenu

    def self.included(base)
      base.class_eval do
        helper_method :organization_navigation
      end
    end

    def menu_organization
      {:key => :organizations,
       :name => _("Organizations"),
        :url => :sub_level,
        :options => {:class=>'organizations top_level', "data-menu"=>"organizations"},
        :if => lambda{current_organization() && Organization.any_readable?},
        :items=> [ menu_org_list, menu_org_subscriptions]
      }
    end


    def menu_org_list
      {:key => :org_list,
       :name => _("List"),
       :url => organizations_path,
       :options => {:class=>'organizations second_level', "data-menu"=>"organizations"}
      }
    end

    def menu_org_subscriptions
      {:key => :subscriptions,
       :name => _("Subscriptions"),
       :url => subscriptions_path(),
       :options => {:class=>'organizations second_level', "data-menu"=>"organizations"}
      }
    end

    def organization_navigation
      [
        { :key => :details,
          :name =>_("Details"),
          :url => lambda{edit_organization_path(@organization.cp_key)},
          :if => lambda{@organization},
          :options => {:class=>"navigation_element"}
        },
        { :key => :history,
          :name =>_("History"),
          :url => lambda{events_organization_path(@organization.cp_key)},
          :if => lambda{@organization},
          :options => {:class=>"navigation_element"}
        }
      ]
    end
  end
end
