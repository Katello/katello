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

require 'resources/candlepin'

class Api::CandlepinProxiesController < Api::ProxiesController

  def get
    r = ::Candlepin::Proxy.get(@request_path)
    render :text => r, :content_type => :json
  end

  def delete
    head ::Candlepin::Proxy.delete(@request_path).code.to_i
  end

  def post
    render :text => ::Candlepin::Proxy.post(@request_path, @request_body), :content_type => :json
  end
  
end