#
# Copyright 2012 Red Hat, Inc.
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

class ChangesetTest < MiniTest::Rails::ActiveSupport::TestCase

  def setup
    models = ["Organization", "KTEnvironment"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
  end

  def test_add_content_view_exception
    changeset = FactoryGirl.build_stubbed(:promotion_changeset)
    library   = FactoryGirl.build_stubbed(:library)
    env       = FactoryGirl.build_stubbed(:environment)
    view      = FactoryGirl.build_stubbed(:content_view)
    env.stub(:prior, library) do
      changeset.environment = env

      assert_empty library.content_views
      assert_raises(Errors::ChangesetContentException) do
        changeset.add_content_view!(view)
      end
    end
  end

  def test_content_view_changeset_promotion
    env          = FactoryGirl.create(:environment, :with_library)
    content_view = FactoryGirl.create(:content_view)
    changeset    = FactoryGirl.create(:promotion_changeset,
                                      :environment => env)

    assert_raises(Errors::ChangesetContentException) do
      changeset.add_content_view!(content_view)
    end
    env.prior.content_views << content_view
    refute_includes changeset.content_views, content_view

    assert changeset.add_content_view!(content_view)
    assert_includes changeset.content_views, content_view
  end

  def test_invalid_content_view_changeset_apply
    org          = FactoryGirl.create(:organization)
    content_view = FactoryGirl.create(:content_view,
                                      :organization => org)
    library      = FactoryGirl.create(:library,
                                      :content_views => [content_view])
    env          = FactoryGirl.create(:environment,
                                      :priors => [library],
                                      :organization => org,
                                      :content_views => [content_view]
                                     )
    changeset    = FactoryGirl.create(:promotion_changeset,
                                      :environment => env,
                                      :state => Changeset::REVIEW)

    content_view.update_attribute(:name, "")
    changeset.add_content_view!(content_view.reload)
    assert_raises(ActiveRecord::RecordInvalid) do
      changeset.apply
    end
  end

  def test_content_view_changeset_apply
    org          = FactoryGirl.create(:organization)
    content_view = FactoryGirl.create(:content_view,
                                      :organization => org)
    library      = FactoryGirl.create(:library,
                                      :content_views => [content_view])
    env          = FactoryGirl.create(:environment,
                                      :priors => [library],
                                      :organization => org,
                                      :content_views => [content_view]
                                     )

    #KTEnvironment.any_instance.stubs(:update_cp_content, true).returns(true)
    changeset    = FactoryGirl.create(:promotion_changeset,
                                      :environment => env,
                                      :state => Changeset::REVIEW)
    assert changeset.add_content_view!(content_view), content_view
    # assert changeset.apply( :async => false, :notify => false )
  end

end