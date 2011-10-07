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
  module ContentMenu
    def self.included(base)
      base.class_eval do
        helper_method :custom_provider_navigation
      end
    end

    def custom_provider_navigation
      [
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
    end

    def menu_contents
      {:key => :content,
       :name => N_("Content Management"),
        :url => :sub_level,
        :class=>'content',
        :items=> [ menu_providers  ]
      }
    end

    def menu_providers

      {:key => :providers,
       :name =>N_("Providers"),
       :url => :sub_level,
       :options => {:highlights_on => /(\/organizations\/.*\/providers)|(\/providers\/.*\/(products|repos))/},
       :if => :sub_level,
       :items => [menu_redhat_providers, menu_custom_providers]
      }

    end

    def menu_redhat_providers
      {:key => :redhat_providers,
        :name =>N_("Red Hat"),
        :url => redhat_provider_providers_path,
        :if => lambda{current_organization && current_organization.readable?},
        :options => {:class=>"third_level"}
      }
    end

    def menu_custom_providers
      {:key => :custom_providers,
        :name =>N_("Custom"),
        :url => lambda{organization_providers_path(current_organization())},
        :if => lambda{current_organization && Provider.any_readable?(current_organization())},
        :options => {:class=>"third_level"}
      }
    end
  end
end