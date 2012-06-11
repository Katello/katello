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
require 'navigation/content_management'
require 'navigation/administration'
require 'navigation/main'

module Menu

  def self.included(base)
    base.send :include, Navigation
    base.class_eval do
      helper_method :render_menu
      helper_method :render_sublevel_menu
      helper_method :render_main_menu
      helper_method :render_main_sub_menu
      helper_method :render_admin_menu
    end
  end
  def render_menu(level, items = nil, prune = true)
    items ||= menu_main
    prune_menu(items) if prune
    render_navigation(:items=>items, :expand_all=>true, :level => level)
  end

  def render_main_menu()
    prune = @main_nav.nil?
    @main_nav ||= menu_main
    render_menu(1, @main_nav, prune)
  end

  def render_admin_menu()
    items = admin_main
    prune_menu(items)
    render_navigation(:items=>items, :expand_all=>true) unless items.empty?
  end

  def render_main_sub_menu()
    prune = @main_nav.nil?
    @main_nav ||= menu_main
    render_sublevel_menu(@main_nav, prune)
  end

  def render_sublevel_menu(items = nil, prune = true)
    items ||= menu_main
    prune_menu(items) if prune
    items.collect do |top_level|
      render_navigation(:items => top_level[:items], :expand_all=>true) if top_level[:items]
    end.compact.join("").html_safe
  end


  private
  def prune_menu menu_items
    #have a list of menu items -> example [dashboard_hash, organizations_hash]
    #we need to prune that list based on
    #1. :if block wont pass (Permission issues  -> eg: user has no org access)   OR
    #2. No accessible children (-> eg: none of the second level items under org work out for the user)
    menu_items.delete_if do |menu|
      # check the :if block
      if_proc =  menu.delete(:if)
      if (!if_proc) || if_proc == :sub_level || if_proc.call
         # :if block worked out.
         # Checking the children
         if menu[:items]
           menu[:items] = menu[:items].call if Proc === menu[:items]
           # prune the sub menus
           prune_menu(menu[:items]) if menu[:items]

           # now that they have been pruned, set the default url.
           # pick that from the first accessible child
           if (!menu[:url] || menu[:url] == :sub_level) && !menu[:items].empty?
             menu[:url] = menu[:items][0][:url]
           end

           menu[:url] =  menu[:url].call if Proc===menu[:url]

           #we want this item to be pruned
           # if there are no accessible children

           menu[:items].empty?
         else
           # this is a leaf node
           # and its condition has already been evaluated to true
           # so keep it
           menu[:url] =  menu[:url].call if Proc===menu[:url]
           false
         end
      else
        # This node's condition has been evaluated to false
        # so prune it.
        true
      end
    end
  end

end