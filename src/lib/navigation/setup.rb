
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

    def menu_setup
      menu = {:key => :setup,
       :name => _("Setup"),
        :url => :sub_level,
        :options => {:class=>'setup top_level', "data-menu"=>"setup"},
        :items=> [ menu_architectures, menu_locations, menu_domains, menu_smart_proxies, menu_subnets, menu_hardware_models ]
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

    def menu_subnets
      {:key => :subnets,
       :name => _("Subnets With Really Long Text Ok How"),
       :url => subnets_path,
       :if => lambda{true}, #TODO: check permissions
       :options => {:class=>'setup second_level', "data-menu"=>"setup"}
      }
    end

    def menu_domains
      {:key => :domains,
       :name => _("Domains That Take Up A Lot of Text"),
       :url => domains_path,
       :if => lambda{true}, #TODO: check permissions
       :options => {:class=>'setup second_level', "data-menu"=>"setup"}
      }
    end

    def menu_architectures
      {:key => :architectures,
       :name => _("Architectures Holy Mother of Poo This is Awesome"),
       :url => "",
       :if => lambda{true}, #TODO: check permissions
       :options => {:class=>'setup second_level', "data-menu"=>"setup"}
      }
    end

    def menu_locations
      {:key => :locations,
       :name => _("Locations And Places Where People Might Store Things"),
       :url => "",
       :if => lambda{true}, #TODO: check permissions
       :options => {:class=>'setup second_level', "data-menu"=>"setup"}
      }
    end

    def menu_smart_proxies
      {:key => :smart_proxies,
       :name => _("Smart Proxies That Are Really Long So I Can Test"),
       :url => "",
       :if => lambda{true}, #TODO: check permissions
       :options => {:class=>'setup second_level', "data-menu"=>"setup"}
      }
    end

    def menu_hardware_models
      {:key => :hardware_models,
       :name => _("Hardware Models Please Help Me Oh God My Legs"),
       :url => "",
       :if => lambda{true}, #TODO: check permissions
       :options => {:class=>'setup second_level', "data-menu"=>"setup"}
      }
    end
    
  end
end
