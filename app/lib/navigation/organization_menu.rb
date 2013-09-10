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
        :options => {:class => 'organizations top_level', "data-menu" => "organizations"},
        :if => lambda{current_organization && Organization.any_readable?},
        :items => [menu_org_list]
      }
    end

    def menu_org_list
      {:key => :org_list,
       :name => _("List"),
       :url => organizations_path,
       :options => {:class => 'organizations second_level', "data-menu" => "organizations"}
      }
    end

    def organization_navigation
      [
        { :key => :organization_details,
          :name => _("Details"),
          :url => lambda{edit_organization_path(@organization.label)},
          :if => lambda{@organization},
          :options => {:class => "panel_link"}
        },
        {:key => :organization_default_info,
         :name => _("Default Custom Info"),
         :url => lambda{organization_default_info_path(@organization.label, "system")},
         :if => lambda{@organization},
         :options => {:class => "panel_link menu_parent"},
         :items => default_info_subnav
        },
        { :key => :organization_history,
          :name => _("History"),
          :url => lambda{events_organization_path(@organization.label)},
          :if => lambda{@organization},
          :options => {:class => "panel_link"}
        }
      ]
    end

    def default_info_subnav
      [
        { :key => :org_system_default_info,
          :name => _("System Default Info"),
          :url => lambda{organization_default_info_path(@organization.label, "system")},
          :if => lambda{@organization},
          :options => {:class => "third_level panel_link"}
        },
        { :key => :org_distributor_default_info,
          :name => _("Distributor Default Info"),
          :url => lambda{organization_default_info_path(@organization.label, "distributor")},
          :if => lambda{@organization},
          :options => {:class => "third_level panel_link"}
        }
      ]
    end
  end
end
