require 'models/authorization/authorization_base'

module Katello
  class SyncPlanAuthorizationAdminTest < AuthorizationTestBase
    def setup
      User.current = User.find(users('admin').id)
      @organization = @acme_corporation
      @plan = SyncPlan.new(:name => 'ACME Plan', :organization => @organization, :sync_date => Time.now, :interval => 'daily')
    end

    def test_readable?
      assert @plan.readable?
    end

    def test_editable?
      assert @plan.editable?
    end

    def test_deletable?
      assert @plan.deletable?
    end
  end

  class SyncPlanAuthorizationNoPermsTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('restricted').id)
      @organization = @acme_corporation
      @plan = SyncPlan.new(:name => 'ACME Plan', :organization => @organization, :sync_date => Time.now, :interval => 'daily')
    end

    def test_readable?
      refute @plan.readable?
    end

    def test_editable?
      refute @plan.editable?
    end

    def test_deletable?
      refute @plan.deletable?
    end
  end
end
