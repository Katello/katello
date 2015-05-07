require 'katello_test_helper'

module Katello
  class LabelFromNameTest < ActiveSupport::TestCase
    def test_create_wtih_empty_label
      org = get_organization
      library = KTEnvironment.find(katello_environments(:library).id)
      env = KTEnvironment.create!(:name => "justin11", :organization => org, :prior => library)
      refute_nil env.label
    end

    def test_update_label
      staging = KTEnvironment.find(katello_environments(:staging).id)
      assert_raises ActiveRecord::RecordInvalid do
        staging.update_attributes!(:label => "crazy")
      end
    end
  end
end
