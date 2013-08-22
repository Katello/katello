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

require 'test_helper'
require 'support/auth_support'

module ContentViewAuthBase
  def self.included(base)
    base.class_eval do
      fixtures :all
      include AuthorizationSupportMethods
    end
    base.extend ClassMethods
  end

  def setup
    @admin       = User.find(users(:admin))
    @no_perms    = User.find(users(:no_perms_user))
    @org         = Organization.find(organizations(:acme_corporation))
    @view        = FactoryGirl.build(:content_view, :organization => @org)
  end

  def teardown
    ContentView.delete_all
    User.delete_all
    Organization.delete_all
  end

  module ClassMethods
    def before_suite
      services  = ['Candlepin', 'Pulp', 'ElasticSearch', 'Foreman']
      models    = ['Organization', 'KTEnvironment', 'User']
      disable_glue_layers(services, models)
    end
  end
end

class ContentViewAuthorizationAdminTest < ActiveSupport::TestCase
  include ContentViewAuthBase

  def setup
    super
    User.current = @admin
  end

  def test_readable
    count =  ContentView.readable(@org).count
    @view.save!
    assert ContentView.any_readable?(@org)
    assert @view.readable?
    assert_includes ContentView.readable(@org), @view
    assert_equal ContentView.readable(@org).count, count+1
  end

  def test_promotable
    assert @view.promotable?
  end

  def test_subscribe
    assert @view.subscribable?
  end

end

class ContentViewAuthorizationNoAuthTest < ActiveSupport::TestCase
  include ContentViewAuthBase

  def setup
    super
    User.current = @no_perms
  end

  def test_readable
    refute ContentView.any_readable?(@org)
    assert_empty ContentView.readable(@org)
    refute @view.readable?
  end

  def test_promotable?
    refute @view.promotable?
  end

  def test_subscribable?
    refute @view.subscribable?
  end
end

class ContentViewAuthorizationSinglePermTest < ActiveSupport::TestCase
  include ContentViewAuthBase

  def setup
    super
    User.current = @no_perms
  end

  def test_promotable
    allow User.current.own_role, [:promote], :content_views
    assert @view.promotable?
    assert @view.readable?
    refute @view.subscribable?
  end

  def test_readable
    allow User.current.own_role, [:read], :content_views
    assert ContentView.any_readable?(@org)
    refute @view.promotable?
    @view.save!
    refute_empty ContentView.readable(@org)
  end
end
