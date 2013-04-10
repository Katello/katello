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

class Api::Foreman::DomainsController < Api::Foreman::SimpleCrudController

  resource_description do
    desc <<-DOC
      Foreman considers a domain and a DNS zone as the same thing. That is, if you
      are planning to manage a site where all the machines are or the form
      <i>hostname</i>.<b>somewhere.com</b> then the domain is <b>somewhere.com</b>.
      This allows Foreman to associate a puppet variable with a domain/site
      and automatically append this variable to all external node requests made
      by machines at that site.

      The Domains API is available only if support for Foreman is installed.
    DOC
  end

  def_param_group :domain do
    param :domain, Hash, :required => true, :action_aware => true do
      param :name, String, :required => true, :desc => "The full DNS Domain name"
      param :fullname, String, :desc => "Full name describing the domain"
      param :dns_id, :number, :desc => "DNS Proxy to use within this domain"
      param :domain_parameters_attributes, Array, :desc => "Array of parameters (name, value)"
    end
  end

  self.foreman_model = ::Foreman::Domain

  api :GET, "/domains/", "List of domains"
  param :search, String, :desc => "Filter results"
  param :order, String, :desc => "Sort results"
  def index
    super params.slice('order', 'search')
  end

  api :GET, "/domains/:id/", "Show a domain."
  param :id, String, "domain name (no slashes)"
  def show
    super
  end

  api :POST, "/domains/", "Create a domain."
  description <<-DOC
    The <b>fullname</b> field is used for human readability in reports
    and other pages that refer to domains, and also available as
    an external node parameter
  DOC
  param_group :domain
  def create
    super
  end

  api :PUT, "/domains/:id/", "Update a domain."
  param_group :domain
  def update
    super
  end

  api :DELETE, "/domains/:id/", "Delete a domain."
  param :id, String, "domain name (no slashes)"
  def destroy
    super
  end
end
