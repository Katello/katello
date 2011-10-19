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

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'webrat'
require 'helpers/login_helper_methods'
require 'helpers/authorization_helper_methods'
require 'helpers/locale_helper_methods'
require 'helpers/organization_helper_methods'
require 'helpers/system_helper_methods'
require 'helpers/product_test_data.rb'
require 'helpers/product_helper_methods'
require 'common/models/model_spec_helper'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  [
    [RSpec::Rails::ControllerExampleGroup, :controller],
    [RSpec::Rails::ModelExampleGroup, :model],
    [RSpec::Rails::ViewExampleGroup, :view]
  ].each do |x|
    #This line says add to these files all of the modules necessary to act as a controller spec
    config.include x[0], :type => x[1], :example_group => {
      :file_path => config.escaped_path(["spec","common",x[1].to_s.pluralize])
    }

    config.include x[0], :type => x[1], :example_group => {
      :file_path => config.escaped_path(["spec", AppConfig.app_name, x[1].to_s.pluralize])
    }
  end


  config.include Warden::Test::Helpers

  config.after :all do
    Warden.test_reset!
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
end

Webrat.configure do |config|
  config.mode = :rails
end
