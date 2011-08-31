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

require 'resources/pulp'

class Api::PulpProxiesController < Api::ProxiesController

  # TODO: define authorization rules
  skip_before_filter :authorize

  def get
    r = ::Pulp::Proxy.get(@request_path)
    render :text => r, :content_type => :json
  end

  def delete
    head ::Pulp::Proxy.delete(@request_path).code.to_i
  end

  def post
    render :text => ::Pulp::Proxy.post(@request_path, @request_body), :content_type => :json
  end
  
  # need to unify POST and PUT from rhsm -> katello -> pulp
  def put
    render :text => ::Pulp::Proxy.put(@request_path + '/', params[:_json]), :content_type => :json
  end
  
end
