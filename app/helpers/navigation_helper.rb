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


module NavigationHelper

  def generate_menu
    if !Katello.config.katello?
      main_menu   = Navigation::Menus::Headpin::Main.new(current_organization)
      site_menu   = Navigation::Menus::Headpin::Site.new
    else
      main_menu   = Navigation::Menus::Main.new(current_organization)
      site_menu   = Navigation::Menus::Site.new
    end

    user_menu   = Navigation::Menus::User.new(current_user)

    menu = {
      :location => 'left',
      :items => main_menu.items
    }

    site_menu = {
      :location => 'right',
      :items    => site_menu.items
    }

    user_menu = {
      :location => 'right',
      :items    => [user_menu]
    }

    javascript do
      # TODO Get rid of this ugliness
      (
        'angular.module("Bastion.menu").constant("Menus", {
          menu: ' + menu.to_json + ',
          adminMenu: ' + site_menu.to_json + ',
          userMenu: ' + user_menu.to_json + ',
          notices: ' + add_notices.to_json + '
        });'
      ).html_safe
    end
  end

  def add_notices
    return {
      :count          => Notice.for_user(current_user).for_org(current_organization).count.to_s,
      :url            => notices_path,
      :new_notices_url   => notices_get_new_path
    }
  end

end
