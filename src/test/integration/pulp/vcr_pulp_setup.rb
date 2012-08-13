require 'rubygems'
require 'minitest/autorun'
require 'vcr'
require 'ostruct'
require 'yaml'

require 'active_support/core_ext/class/inheritable_attributes'
require 'active_support/core_ext/hash/indifferent_access'
require 'lib/http_resource'
require 'restclient'
require 'rails'
require 'lib/resource_permissions'
require 'json'

katello_config = YAML.load_file('/etc/katello/katello.yml') rescue nil
if katello_config.nil?
  katello_config = YAML.load_file("#{Rails.root}/config/katello.yml") rescue nil
end

AppConfig = OpenStruct.new(:pulp => OpenStruct.new(katello_config['common']['pulp']))
Rails.logger = Logger.new(STDOUT)

require 'lib/resources/pulp'


VCR.configure do |c|
  c.cassette_library_dir = 'test/integration/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.default_cassette_options = { :record => :all } #forcing all requests to Pulp currently
end

class Resources::Pulp::PulpResource
  def self.default_headers
    {'accept' => 'application/json',
     'accept-language' => I18n.locale,
     'content-type' => 'application/json'}.merge({ 'pulp-user' => 'admin' })
  end
end
