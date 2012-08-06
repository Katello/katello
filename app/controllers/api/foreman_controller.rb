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

class Api::ForemanController < Api::ApiController
  respond_to :json

  skip_before_filter :authorize # TODO

  def self.foreman_api_resource_class
    raise NotImplemented
  end

  def self.foreman
    config = AppConfig.foreman
    #@@foreman_api_resource.new(:username => 'admin', :password => 'changeme', :base_url => cfg.url)
    @foreman_api_resource ||= foreman_api_resource_class.new(:base_url => config.url, 
                                                             :oauth => { :consumer_key => config.oauth_key, 
                                                                         :consumer_secret => config.oauth_secret })
  end 
  
  def api_call(meth, *args)
    data, response = self.class.foreman.send(meth, *args)
    render :text => response.body, :code => response.code, :content_type => :json
  end
end
