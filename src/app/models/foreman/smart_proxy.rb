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

class Foreman::SmartProxy < Resources::ForemanModel
  include Resources::AbstractModel::IndexedModel

  PROXY_FEATURES = %w[TFTP BMC DNS DHCP Puppetca Puppet]

  attributes :name, :url, :features

  def json_default_options
    { :only => [:name, :url] }
  end

  validates :name, :presence => true
  validates :url, :presence => true

  index_options :display_attrs => [:name, :url]

  mapping do
    indexes :id, :type=>'string', :index => :not_analyzed
    indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :url, :type => 'string', :analyzer => :kt_name_analyzer
  end

  class << self

    PROXY_FEATURES.each do |feature|
      send :define_method, (feature.downcase+'_proxies').to_sym do
        return Foreman::SmartProxy.all(:type=>feature)
      end
    end

  end

  private

  def features=(features)
    @features = features.collect { |f| f['feature']['name']}
  end

end
