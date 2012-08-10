require 'minitest/autorun'
require 'vcr'

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../../../config/environment', __FILE__)

VCR.configure do |c|
  c.cassette_library_dir = 'test/integration/fixtures/vcr_cassettes'
  c.hook_into :webmock
end

class Resources::Pulp::PulpResource
  def self.default_headers
    {'accept' => 'application/json',
     'accept-language' => I18n.locale,
     'content-type' => 'application/json'}.merge({ 'pulp-user' => 'admin' })
  end
end
