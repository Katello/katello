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
    end
  end
  def render_menu(level)
    @menu_items ||=create_menu
    render_navigation(:items=>@menu_items, :expand_all=>false, :level => level)
  end

  def create_menu
    ret = menu_main
    ret.delete_if do |top_level|
      if_eval_top = top_level.delete(:if)
      if (!if_eval_top) || if_eval_top == :sub_level || if_eval_top.call
        if top_level[:items]

          top_level[:items].delete_if do |second_level|
            if_eval_second = second_level.delete(:if)
            if (!if_eval_second) || if_eval_second == :sub_level || if_eval_second.call
              if second_level[:items]
                second_level[:items].delete_if do |third_level|
                  if_eval = third_level.delete(:if)
                  if (!if_eval) || if_eval.call
                    false
                  else
                    true
                  end
                end
                if second_level[:url] == :sub_level && !second_level[:items].empty?
                  second_level[:url] = second_level[:items][0][:url]
                end
                second_level[:items].empty?
              else
                false
              end
            else
              #second level if call was false
              true
            end
          end
          if top_level[:url] == :sub_level && !top_level[:items].empty?
            top_level[:url] = top_level[:items][0][:url]
          end

          top_level[:items].empty?
        else
          # top level has no items
          false
        end
      else
        #top level if call was false
        true
      end
    end
    ret
  end
end