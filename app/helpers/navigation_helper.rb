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
    navigation = Experimental::Navigation::Navigation.new

    main_menu   = navigation.generate_main_menu(current_organization)
    admin_menu  = navigation.generate_admin_menu
    user_menu   = navigation.generate_user_menu(current_user)

    menu = {
      :location => 'left',
      :items => main_menu
    }

    admin_menu = {
      :location => 'right',
      :items    => admin_menu
    }

    user_menu = {
      :location => 'right',
      :items    => user_menu
    }

    javascript do
      ("KT.main_menu = " + menu.to_json + ";").html_safe +
      ("KT.admin_menu = " + admin_menu.to_json + ";").html_safe +
      ("KT.user_menu = " + user_menu.to_json + ";").html_safe +
      ("KT.notices = " + add_notices.to_json + ";").html_safe
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
