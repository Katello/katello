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
module Menu

  def self.included(base)
    base.class_eval do
      helper_method :render_menu
    end
  end

  def menu_items
    redhat_providers ={:key => :redhat_providers,
                  :name =>N_("Red Hat"),
                  :url => redhat_provider_providers_path,
                  :if => lambda{current_organization.readable?},
                  :options => {:class=>"third_level"}
                }

    custom_providers ={:key => :custom_providers,
                  :name =>N_("Custom"),
                  :url => organization_providers_path(current_organization()),
                  :if => lambda{Provider.any_readable?(current_organization())},
                  :options => {:class=>"third_level"},
                  :items => @provider.nil? ? [] : [
                      { :key => :edit_custom_providers,
                        :name =>N_("Basics"),
                        :url => (@provider.nil? || @provider.new_record?) ? "" : edit_provider_path(@provider.id),
                        :if => lambda{!@provider.nil? && @provider.readable? && !@provider.new_record?},
                        :options => {:class=>"navigation_element"}
                      },
                      { :key => :products_repos,
                        :name =>N_("Products & Repositories"),
                        :url => (@provider.nil? || @provider.new_record?) ? "" : products_repos_provider_path(@provider.id),
                        :if => lambda{!@provider.nil? && @provider.readable? &&
                                      !@provider.new_record? && !@provider.has_subscriptions?},
                        :options => {:class=>"navigation_element"}
                      }
                  ]
                }



    providers = {:key => :providers,
             :name =>N_("Providers"),
             :url => :sub_level,
             :options => {:highlights_on => /(\/organizations\/.*\/providers)|(\/providers\/.*\/(products|repos))/},
             :if => :sub_level,
             :items =>[ redhat_providers, custom_providers]
            }


    content = {:key => :content,
       :name => N_("Content Management"),
        :url => :sub_level,
        :class=>'content',
        :items=> [ providers  ]
      }

      system =      {:key => :systems,
     :name => N_("Systems"),
     :url => systems_path,
     :class=>'systems',
      }


    [ content, system ]
  end
=begin
{:key => :systems, :name => N_("Systems"),
      :url => systems_path, :class=>'systems',
    :items => [
    ]
},
=end
  def render_menu(level)
    @menu_items ||=create_menu
    render_navigation(:items=>@menu_items, :expand_all=>false, :level => level)
  end

  def create_menu
    ret = menu_items
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