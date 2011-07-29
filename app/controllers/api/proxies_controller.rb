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

class Api::ProxiesController < Api::ApiController
  before_filter :proxy_request_path, :proxy_request_body

  rescue_from RestClient::Exception do |e|
    Rails.logger.error pp_exception(e)
    render :json => {:errors => [e.http_body]}, :status => e.http_code
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
