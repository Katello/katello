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

class Api::ProxiesController < Api::ApiController
  before_filter :proxy_request_path, :proxy_request_body

  rescue_from RestClient::Exception do |e|
    Rails.logger.error e.to_s
    render :text => e.http_body, :status => e.http_code, :content_type => :json
  end

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

  def proxy_request_path
    @request_path = drop_api_namespace(@_request.fullpath)
  end

  def proxy_request_body
    @request_body = @_request.body
  end

  def drop_api_namespace(original_request_path)
    original_request_path.gsub('/api', '')
  end

end
