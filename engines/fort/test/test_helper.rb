# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../../../test/base_test_helper.rb",  __FILE__)
require "rails/test_help"

class MiniTest::Rails::ActiveSupport::TestCase
  self.fixture_path = File.expand_path('../../../../test/fixtures/models', __FILE__)
end

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
