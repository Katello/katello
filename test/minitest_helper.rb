
require 'base_test_helper'


class MiniTest::Rails::ActiveSupport::TestCase
  self.fixture_path = File.expand_path('../fixtures/models', __FILE__)
end