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
  module AdministrationMenu
    def self.included(base)
      base.class_eval do
        helper_method :user_navigation
      end
    end

    def user_navigation
      [
        { :key => :environment,
          :name =>_("Environments"),
          :url => lambda{edit_environment_user_path(@user.id)},
          :if => lambda {@user},
          :options => {:class=>"panel_link"}
        },
        { :key => :user_roles,
          :name =>_("Roles"),
          :url => lambda{edit_role_path(@user.own_role_id)},
          :if => lambda{@user},
          :options => {:class=>"panel_link"}
        },
        { :key => :user_details,
          :name =>_("Details"),
          :url => lambda{edit_user_path(@user.id)},
          :if => lambda{@user},
          :options => {:class=>"panel_link"}
        }
      ]
    end

    def menu_administration
      menu = {:key => :admin,
       :name => _("Administer"),
        :url => :sub_level,
        :items=> [ menu_users, menu_roles, menu_orgs ],
        :options => {:class=>'operations header-widget fl menu_parent', "data-menu"=>"operations"},
        :if => :sub_level
      }
      menu[:items] << menu_sync_tasks if AppConfig.katello?
      menu[:items] << menu_about # keep the about as the last item
      return menu
    end


    def menu_users
      {:key => :users,
       :name => _("Users"),
       :url => users_path,
       :if =>lambda {User.any_readable?},
       :options => {:class=>'operations second_level', "data-menu"=>"operations"}
      }
    end

    def menu_roles
      {:key => :roles,
       :name => _("Roles"),
       :url => roles_path,
       :if =>lambda {Role.any_readable?},
       :options => {:class=>'operations second_level', "data-menu"=>"operations"}
      }
    end

    def menu_orgs
      {:key => :orgs,
       :name => _("Manage Organizations"),
       :url => organizations_path,
       :if =>lambda {Organization.any_readable?},
       :options => {:class=>'operations section_level', "data-menu"=>"operations"}
      }
    end

    def menu_sync_tasks
      {:key => :sync_tasks,
       :name => _("Synchronization"),
       :url => sync_management_manage_path,
       :if => lambda {User.current.has_superadmin_role?},
       :options => {:class=>'operations section_level', "data-menu"=>"operations"}
      }
    end

    def menu_about
      {:key => :about,
       :name => _("About"),
       :url => about_path,
       :if => lambda {Organization.any_readable?},
       :options => {:class=>'operations section_level', "data-menu"=>"operations"}
      }
    end

  end
end
