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

require 'katello_test_helper'

module Katello
  class ChangesetTest < ActiveSupport::TestCase

    def self.before_suite
      models = ["Organization", "KTEnvironment", "ContentViewEnvironment", "Repository", "ContentView",
                "ContentViewVersion"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
    end

    def setup
      @acme_corporation     = get_organization(:organization1)

      @library              = KTEnvironment.find(katello_environments(:library).id)
      @dev                  = KTEnvironment.find(katello_environments(:dev).id)
      @library_view         = ContentView.find(katello_content_views(:library_view))
      @library_dev_view     = ContentView.find(katello_content_views(:library_dev_view))
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

    def test_add_content_view_check_promotion_exception
      changeset = Factory.build(:promotion_changeset)
      changeset.environment = @dev

      assert_raises(Errors::ChangesetContentException) do
        changeset.add_content_view!(@library_dev_view)
      end
    end

    def test_content_view_changeset_promotion
      skip 'skipped temporarily to get travis tests working'
      Repository.any_instance.stubs(:clone_contents).returns([])
      view = @library_view
      after_dev    = FactoryGirl.create(:environment, :prior=>@dev)
      changeset    = FactoryGirl.create(:promotion_changeset,
                                        :environment => after_dev)

      assert_raises(Errors::ChangesetContentException) do
        changeset.add_content_view!(view)
      end

      view.promote(@library, @dev)
      refute_includes changeset.content_views, view

      changeset.reload
      view.reload

      assert changeset.add_content_view!(view)
      assert_includes changeset.content_views, view
    end

    def test_invalid_content_view_changeset_apply
      changeset    = FactoryGirl.create(:promotion_changeset,
                                        :environment => @dev,
                                        :state => Changeset::REVIEW)

      @library_view.update_attribute(:name, "")
      changeset.add_content_view!(@library_view)
      assert_raises(ActiveRecord::RecordInvalid) do
        changeset.apply
      end
    end

    def test_content_view_changeset_apply
      changeset    = FactoryGirl.create(:promotion_changeset,
                                        :environment => @dev,
                                        :state => Changeset::REVIEW)
      assert_equal changeset.add_content_view!(@library_view), [@library_view, nil]
      # assert changeset.apply(:async => false, :notify => false)
    end

    def test_invalid_content_view_deletion_changeset
      view         = @library_view
      changeset    = FactoryGirl.create(:deletion_changeset,
                                        :environment => @dev)

      assert_raises(Errors::ChangesetContentException) do
        changeset.add_content_view!(view)
      end
      assert_raises(Errors::ChangesetContentException) do
        view.delete(@dev)
      end
      refute_includes changeset.content_views, view
    end

    def test_content_view_invalid_library_deletion
      view = @library_dev_view

      assert_raises(Errors::ChangesetContentException) do
        view.delete(@library)
      end
    end

    def test_content_view_changeset_deletion
      view         = @library_dev_view
      changeset    = FactoryGirl.create(:deletion_changeset,
                                        :environment => @dev)

      assert changeset.add_content_view!(view)
      assert_includes changeset.content_views.reload.map(&:id), view.id
      view.delete(@dev)
      refute_includes @dev.content_views(true), view

      view.delete(@library)
      assert_nil ContentView.find_by_id(view.id)
    end

    def test_content_view_re_promote
      view         = @library_dev_view
      changeset    = FactoryGirl.create(:deletion_changeset,
                                        :environment => @dev)

      assert changeset.add_content_view!(view)
      view.delete(@dev)
      refute_includes @dev.content_views(true), view

      # re-promote
      changeset    = FactoryGirl.create(:promotion_changeset,
                                        :environment => @dev)
      assert view.promote(@library, @dev)
      assert_includes @dev.content_views(true), view
    end

    def test_content_view_promotion_during_publish_or_refresh
      task = FactoryGirl.create(:task_status, :user => User.find(users(:admin)))
      ContentViewVersion.any_instance.stubs(:task_status).returns(task)
      TaskStatus.any_instance.stubs(:pending?).returns(true)

      content_view = ContentView.find(katello_content_views(:library_view))

      changeset = FactoryGirl.create(:promotion_changeset,
                                     :environment => @dev,
                                     :state => Changeset::REVIEW)
      changeset.add_content_view!(content_view)

      task.task_type = TaskStatus::TYPES[:content_view_publish][:type]
      assert_raises(Errors::ContentViewTaskInProgress) do
        changeset.apply
      end

      task.task_type = TaskStatus::TYPES[:content_view_refresh][:type]
      assert_raises(Errors::ContentViewTaskInProgress) do
        changeset.apply
      end
    end

    def test_destroy
      content_view = ContentView.find(katello_content_views(:library_view))

      changeset = FactoryGirl.create(:promotion_changeset,
                                     :environment => @dev)
      changeset.add_content_view!(content_view)

      assert changeset.destroy
    end
  end
end
