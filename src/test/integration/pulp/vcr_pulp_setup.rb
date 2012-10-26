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

require 'rubygems'
require 'vcr'
require 'ostruct'
require 'yaml'

require 'active_support/core_ext/class/inheritable_attributes'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/to_param'
require 'active_support/core_ext/object/to_query'
require 'restclient'
require 'rails'
require 'json'

require './lib/http_resource'
require './lib/resource_permissions'

katello_config = YAML.load_file('/etc/katello/katello.yml') rescue nil
if katello_config.nil?
  katello_config = YAML.load_file("#{Rails.root}/config/katello.yml") rescue nil
end

AppConfig = OpenStruct.new(:pulp => OpenStruct.new(katello_config['common']['pulp']))
Rails.logger = Logger.new(STDOUT)

require 'lib/resources/pulp'


def configure_vcr(record_mode=:all)
  VCR.configure do |c|
    c.cassette_library_dir = 'test/integration/fixtures/vcr_cassettes'
    c.hook_into :webmock
    c.default_cassette_options = { :record => record_mode } #forcing all requests to Pulp currently
  end
end

class Resources::Pulp::PulpResource
  def self.default_headers
    {'accept' => 'application/json',
     'accept-language' => I18n.locale,
     'content-type' => 'application/json'}.merge({ 'pulp-user' => 'admin' })
  end
end
