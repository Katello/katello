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
    navigation = Experimental::Navigation::Menu.new(current_organization)
    main_menu_items = navigation.generate_main_menu
    admin_items = navigation.generate_admin_menu

    menu = {
      :location => 'left',
      :items => main_menu_items
    }

    admin_menu = {
      :location => 'right',
      :items    => admin_items
    }

    user_menu = {
      :location => 'right',
      :items => [{
        :display=> current_user.username,
        :type   => 'dropdown',
        :items  => [
          {
            :display=> _("My Account"),
            :url    => "#{users_path(current_user)}#panel=user_#{current_user.id}"
          },{
            :display=> _("Sign Out"),
            :url    => logout_path
        }]
      }]
    }

    javascript do
      ("KT.main_menu = " + menu.to_json + ";").html_safe +
      ("KT.user_menu = " + user_menu.to_json + ";").html_safe +
      ("KT.admin_menu = " + admin_menu.to_json + ";").html_safe +
      ("KT.notices = " + add_notices.to_json + ";").html_safe
    end
  end

  def add_notices
    display = '<span>'
    display += '<i class="validation_icon-white icon"></i>'
    display += Notice.for_user(current_user).for_org(current_organization).count.to_s
    display += '</span>'

    return {
      :display=> display,
      :url    => notices_path
    }
  end

end
