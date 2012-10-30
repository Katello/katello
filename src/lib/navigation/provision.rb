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
  module ProvisionMenu

    def menu_provision
      {
        :key => :provision,
        :name => _("Provisioning"),
        :url => false,
        :options => {
          :class=>'provision top_level', "data-menu"=>"provision",
          :container_id=>'provisionContainer',
          :link => {:id=>'provisionButton'}},
        :items=> [
          menu_architectures, menu_domains, menu_hwmodels,
          menu_installation_media, menu_operating_systems,
          menu_partition_tables, menu_provisioning_templates,
          menu_subnets
        ],
        :if => lambda{current_organization && current_organization.provisioning_readable?}
      }
    end

    def menu_architectures
      {
        :key => :architectures,
        :name => _("Architectures"),
        #TODO: change to the real path when the controller is ready
        :url => dashboard_index_path,
        :if => lambda{current_organization},
        :options => {:class=>'provision second_level', "data-menu"=>"provision",
          :container_id=>'provisionBox'},
        :class => "abc"
      }
    end

    def menu_domains
      {:key => :domains,
       :name => _("Domains"),
       #TODO: change to the real path when the controller is ready
       :url => dashboard_index_path,
       :if => lambda{current_organization},
       :options => {:class=>'provision second_level', "data-menu"=>"provision"}
      }
    end

    def menu_hwmodels
      {:key => :hwmodels,
        :name => _("Hardware Models"),
        #TODO: change to the real path when the controller is ready
        :url => dashboard_index_path,
        :if => lambda {current_organization},
        :options => {:class=>'provision second_level', "data-menu"=>"provision"}
       }
    end

    def menu_installation_media
      {:key => :installation_media,
       :name => _("Installation Media"),
       #TODO: change to the real path when the controller is ready
       :url => dashboard_index_path,
       :if => lambda{current_organization},
       :options => {:class=>'provision second_level', "data-menu"=>"provision"}
      }
    end

    def menu_operating_systems
      {:key => :operating_systems,
       :name => _("Operating Systems"),
       :url => dashboard_index_path,
       #TODO: change to the real path when the controller is ready
       :if => lambda{current_organization},
       :options => {:class=>'provision second_level', "data-menu"=>"provision"}
      }
    end

    def menu_partition_tables
      {:key => :partition_tables,
       :name => _("Partition Tables"),
       :url => dashboard_index_path,
       #TODO: change to the real path when the controller is ready
       :if => lambda{current_organization},
       :options => {:class=>'provision second_level', "data-menu"=>"provision"}
      }
    end

    def menu_provisioning_templates
      {:key => :provisioning_templates,
       :name => _("Provisioning Templates"),
       :url => dashboard_index_path,
       #TODO: change to the real path when the controller is ready
       :if => lambda{current_organization},
       :options => {:class=>'provision second_level', "data-menu"=>"provision"}
      }
    end

    def menu_subnets
      {:key => :subnets,
       :name => _("Subnets"),
       #TODO: change to the real path when the controller is ready
       :url => dashboard_index_path,
       :if => lambda{current_organization},
       :options => {:class=>'provision second_level', "data-menu"=>"provision"}
      }
    end
  end
end
