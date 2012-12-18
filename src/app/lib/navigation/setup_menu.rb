
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
  module SetupMenu

    def self.included(base)
      base.class_eval do
        helper_method :configuration_template_navigation
      end
    end

    def menu_setup
      menu = {:key => :setup,
       :name => _("Setup"),
        :url => :sub_level,
        :options => {:class=>'setup top_level', "data-menu"=>"setup"},
        :items=> [ menu_smart_proxies, menu_subnets, menu_domains, menu_architectures, menu_hw_models, menu_configuration_templates]
        # TODO: final order of the setup menu items
        #   Setup
        #   Locations
        #   Smart Proxies
        #   Subnets
        #   Domains
        #   Hardware Models
        #   Architectures
      }
      menu
    end

    def menu_smart_proxies
      {:key => :registered,
       :name => _("Smart Proxies"),
       :url => smart_proxies_path,
       :if => lambda{true}, #TODO: check permissions
       :options => {:class=>'setup second_level', "data-menu"=>"smart_proxies"}
      }
    end

    def menu_subnets
      {:key => :subnets,
       :name => _("Subnets"),
       :url => subnets_path,
       :if => lambda{true}, #TODO: check permissions
       :options => {:class=>'setup second_level', "data-menu"=>"subnets"}
      }
    end

    def menu_domains
      {:key => :domains,
       :name => _("Domains"),
       :url => domains_path,
       :if => lambda{true}, #TODO: check permissions
       :options => {:class=>'setup second_level', "data-menu"=>"domains"}
      }
    end

    def menu_architectures
      {:key => :architectures,
       :name => _("Architectures"),
       :url => architectures_path,
       :if => lambda{true}, #TODO: check permissions
       :options => {:class=>'setup second_level', "data-menu"=>"subnets"}
      }
    end

    def menu_hw_models
      {:key => :hw_models,
       :name => _("Hardware Models"),
       :url => hardware_models_path,
       :if => lambda{true}, #TODO: check permissions
       :options => {:class=>'setup second_level', "data-menu"=>"hardware_models"}
      }
    end

    def menu_configuration_templates
      {:key => :registered,
       :name => _("Configuration Templates"),
       :url => configuration_templates_path,
       :if => lambda{true}, #TODO: check permissions
       :options => {:class=>'setup second_level', "data-menu"=>"configuration_templates"}
      }
    end

    def configuration_template_navigation
      [
        { :key => :show_configuration_template,
          :name =>_("Show"),
          :url => lambda{edit_configuration_template_path(@configuration_template)},
          :if => lambda{true},
          :options => {:class=>"panel_link"}
        },
        { :key => :configuration_template_associations,
          :name =>_("Associations"),
          :url => lambda{associations_configuration_template_path(@configuration_template)},
          :if => lambda{true},
          :options => {:class=>"panel_link"}
        }
      ]
    end
  end
end
