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

$:.unshift(__FILE__, ".") #add  current path to the classpath

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
if RUBY_VERSION >= "1.9"
  require 'simplecov'
end
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
require 'helpers/repository_helper_methods'
require 'models/model_spec_helper'
require "helpers/user_helper_methods"
require "helpers/search_helper_methods"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each do |f|
  require f unless f =~ /monkey/
end

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

#  config.include Rack::Test::Methods

  config.include Warden::Test::Helpers
  config.include CustomMatchers

  config.after :all do
    Warden.test_reset!
  end

  # log which test is running
  config.before :each do
    Rails.logger.info "Running test: #{example.metadata[:example_group][:full_description]} #{example.description}"
  end

  # reset locale to English before each test
  config.before :each do
    I18n.locale = :en
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  if !File.directory?("#{Rails.root}/tmp")
    Dir.mkdir("#{Rails.root}/tmp")
  end

end

Webrat.configure do |config|
  config.mode = :rails
end

require 'spec/support/monkey_rspec_trac_creation_line_of_mocks' # has to be loaded after RSpec

include FactoryGirl::Syntax::Methods
