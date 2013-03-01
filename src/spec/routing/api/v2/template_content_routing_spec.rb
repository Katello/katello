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

require "spec_helper"

describe Api::V1::TemplatesContentController do
  describe "routing" do

    let(:tpl_content_controller) { "api/v1/templates_content" }

    it {{ :post =>   "/api/templates/1/packages" }.should   route_to(:controller => tpl_content_controller, :action => "add_package", :template_id => "1")}
    it {{ :delete => "/api/templates/1/packages/2" }.should route_to(:controller => tpl_content_controller, :action => "remove_package", :template_id => "1", :id => "2")}

    it {{ :post =>   "/api/templates/1/parameters" }.should   route_to(:controller => tpl_content_controller, :action => "add_parameter", :template_id => "1")}
    it {{ :delete => "/api/templates/1/parameters/2" }.should route_to(:controller => tpl_content_controller, :action => "remove_parameter", :template_id => "1", :id => "2")}

    it {{ :post =>   "/api/templates/1/package_groups" }.should   route_to(:controller => tpl_content_controller, :action => "add_package_group", :template_id => "1")}
    it {{ :delete => "/api/templates/1/package_groups/2" }.should route_to(:controller => tpl_content_controller, :action => "remove_package_group", :template_id => "1", :id => "2")}

    it {{ :post =>   "/api/templates/1/package_group_categories" }.should   route_to(:controller => tpl_content_controller, :action => "add_package_group_category", :template_id => "1")}
    it {{ :delete => "/api/templates/1/package_group_categories/2" }.should route_to(:controller => tpl_content_controller, :action => "remove_package_group_category", :template_id => "1", :id => "2")}

    it {{ :post =>   "/api/templates/1/distributions" }.should   route_to(:controller => tpl_content_controller, :action => "add_distribution", :template_id => "1")}
    it {{ :delete => "/api/templates/1/distributions/2" }.should route_to(:controller => tpl_content_controller, :action => "remove_distribution", :template_id => "1", :id => "2")}

    it {{ :post =>   "/api/templates/1/repositories" }.should   route_to(:controller => tpl_content_controller, :action => "add_repo", :template_id => "1")}
    it {{ :delete => "/api/templates/1/repositories/2" }.should route_to(:controller => tpl_content_controller, :action => "remove_repo", :template_id => "1", :id => "2")}

  end
end
