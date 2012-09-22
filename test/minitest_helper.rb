ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

require 'minitest/autorun'
require 'minitest/rails'

class MiniTest::Rails::ActiveSupport::TestCase
  #fixtures :users
end

def configure_vcr
  require "vcr"

  #def configure_vcr(record_mode=:all)
  VCR.configure do |c|
    c.cassette_library_dir = 'test/fixtures/vcr_cassettes'
    c.hook_into :webmock
    c.default_cassette_options = { :record => :all } #record_mode } #forcing all requests to Pulp currently
  end
end
