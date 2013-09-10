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

require 'minitest_helper'
require 'support/auth_support'

module ContentViewDefinitionAuthBase
  def self.included(base)
    base.class_eval do
      fixtures :all
    end
    base.extend ClassMethods
  end

  def setup
    @admin       = User.find(users(:admin))
    @no_perms    = User.find(users(:no_perms_user))
    @org         = Organization.find(organizations(:acme_corporation))
    @cvd         = FactoryGirl.create(:content_view_definition, :organization => @org)
  end

  def teardown
    ContentViewDefinition.delete_all
  end

  module ClassMethods
    def before_suite
      services  = ['Candlepin', 'Pulp', 'ElasticSearch', 'Foreman']
      models    = ['Organization', 'KTEnvironment', 'User']
      disable_glue_layers(services, models)
    end
  end
end

class ContentViewDefinitionAuthorizationAdminTest < MiniTest::Rails::ActiveSupport::TestCase
  include ContentViewDefinitionAuthBase

  def setup
    super
    User.current = @admin
  end

  def test_readable
    assert ContentViewDefinition.any_readable?(@org)
    assert @cvd.readable?
    assert ContentViewDefinition.readable(@org).length > 0
  end

  def test_creatable
    assert ContentViewDefinition.creatable?(@org)
  end

  def test_editable
    assert ContentViewDefinition.editable(@org).length > 0
    assert @cvd.editable?
  end

  def test_deletable
    assert @cvd.deletable?
  end

  def test_no_user
    User.current = nil
    assert_raises Errors::UserNotSet do
      ContentViewDefinition.any_readable?(@org)
    end
  end

end

class ContentViewDefinitionAuthorizationNoPermTest < MiniTest::Rails::ActiveSupport::TestCase
  include ContentViewDefinitionAuthBase

  def setup
    super
    User.current = @no_perms
    @cvd.organization = @org
  end

  def test_readable
    refute ContentViewDefinition.any_readable?(@org)
    assert_equal 0, ContentViewDefinition.readable(@org).length
    refute @cvd.readable?
  end

  def test_creatable
    refute ContentViewDefinition.creatable?(@org)
  end

  def test_editable
    refute @cvd.editable?
    assert_equal 0, ContentViewDefinition.editable(@org).length
  end

  def test_deletable
    refute @cvd.deletable?
  end
end

class ContentViewDefinitionAuthorizationReadonlyTest < MiniTest::Rails::ActiveSupport::TestCase
  include ContentViewDefinitionAuthBase, AuthorizationSupportMethods

  def setup
    super
    User.current = @no_perms
    allow User.current.own_role, [:read], :content_view_definitions
  end

  def test_readable
    assert ContentViewDefinition.any_readable?(@org)
    assert_includes ContentViewDefinition.readable(@org), @cvd
    assert @cvd.readable?
  end

  def test_creatable
    refute ContentViewDefinition.creatable?(@org)
  end

  def test_editable
    refute @cvd.editable?
    assert_equal 0, ContentViewDefinition.editable(@org).length
  end

  def test_deletable
    refute @cvd.deletable?
  end
end

# random permission
class ContentViewDefinitionAuthorizationTest < MiniTest::Rails::ActiveSupport::TestCase
  include ContentViewDefinitionAuthBase, AuthorizationSupportMethods

  def setup
    super
    User.current = @no_perms
  end

  def test_publishable
    allow User.current.own_role, [:publish], :content_view_definitions
    assert @cvd.publishable?
    assert ContentViewDefinition.any_readable?(@org)
    assert @cvd.readable?
    refute @cvd.editable?
    refute @cvd.deletable?
  end

end