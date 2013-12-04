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
module NavigationHelper

  def generate_menu
    javascript do
      # TODO: Get rid of this ugliness
      (
        'angular.module("Bastion.menu").constant("Menus", {
          menu: ' + main_menu.to_json + ',
          adminMenu: ' + site_menu.to_json + ',
          bannerMenu: ' + banner_menu.to_json + ',
          notices: ' + add_notices.to_json + ',
          foremanMenu: ' + foreman_menu.to_json + '
        });'
      ).html_safe
    end
  end

  def add_notices
    return {
      :count          => Notice.for_user(User.current).for_org(current_organization).count.to_s,
      :url            => notices_path,
      :new_notices_url   => notices_get_new_path
    }
  end

  def main_menu
    if !Katello.config.katello?
      items = Navigation::Menus::Headpin::Main.new(current_organization).items
    else
      items = Navigation::Menus::Main.new(current_organization).items
    end

    {:location => 'left', :items => items}
  end

  def foreman_menu
    menu = {}

    if defined?(KatelloForemanEngine)
      menu[:url] = Katello.config.foreman.url
    end

    menu
  end

  def banner_menu
    items = Navigation::Menus::Banner.new(current_user).items

    {:location => 'right', :items => items}
  end

  def site_menu
    if !Katello.config.katello?
      items = Navigation::Menus::Headpin::Site.new.items
    else
      items = Navigation::Menus::Site.new.items
    end

    {:location => 'right', :items => items}
  end

end
end
