#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class Api::Foreman::SmartProxiesController < Api::Foreman::SimpleCrudController

  resource_description do
    desc <<-DOC
      A smart proxy is an autonomous web-based foreman component that is placed on
      a host performing a specific function in the host commissioning phase.
      It receives requests from Foreman to perform operations that are required
      during the commissioning process and executes them on its behalf. 
      More details can be found on the Foreman Architecture page.

      To fully manage the commissioning process then a smart proxy 
      will have to manipulate these services, DHCP, DNS, Puppet CA, Puppet and TFTP. 
      These services may exist on separate machines or several of them may be hosted 
      on the same machine. As each smart proxy instance is capable of managing all 
      of these services, there is only need for one proxy per host.

      The Domains API is available only if support for Foreman is installed.
    DOC
  end

  self.foreman_model = ::Foreman::SmartProxy

  api :GET, "/smart_proxies/", "List of smart proxies"
  param :search, String, :desc => "Filter results"
  param :order, String, :desc => "Sort results"
  def index
    super params.slice('order', 'search')
  end

  api :GET, "/smart_proxies/:id/", "Show a smart proxy."
  param :id, String, "domain name (no slashes)"
  def show
    super
  end

  api :POST, "/smart_proxies/", "Create a smart proxy."
  description <<-DOC
    The <b>fullname</b> field is used for human readability in reports
    and other pages that refer to domains, and also available as
    an external node parameter
  DOC
  param :smart_proxy, Hash, :required => true do
    param :name, String, :required => true, :desc => "The smart proxy name"
    param :url, String, :required => true, :desc => "The smart proxy URL starting with 'http://' or 'https://'"
  end
  def create
    super
  end

  api :PUT, "/smart_proxies/:id/", "Update a smart proxy."
  param :smart_proxy, Hash, :required => true do
    param :name, String, :required => false, :desc => "The smart proxy name"
    param :url, String, :required => false, :desc => "The smart proxy URL starting with 'http://' or 'https://'"
  end
  def update
    super
  end

  api :DELETE, "/smart_proxies/:id/", "Delete a domain."
  param :id, String, "domain name (no slashes)"
  def destroy
    super
  end
end

