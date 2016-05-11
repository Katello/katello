require 'katello_test_helper'

module Katello
  class ContentViewHistoryTest < ActiveSupport::TestCase
    def setup
      @organization        = get_organization
      @library             = KTEnvironment.find(katello_environments(:library).id)
      @library_view        = ContentView.find(katello_content_views(:library_view).id)
    end

    def test_no_task
      history = ::Katello::ContentViewHistory.create!(:katello_content_view_version_id => @library_view.versions.first.id,
                                                      :status => 'successful', :user => User.first)

      assert history.humanized_action.is_a?(String)
    end

    def test_promote_no_environment
      task = ForemanTasks::Task.create!(:label => 'Actions::Katello::ContentView::Promote', :state => 'success',
                                        :type => 'ForemanTasks::Task::DynflowTask', :result => 'stopped')
      history = ::Katello::ContentViewHistory.create!(:katello_content_view_version_id => @library_view.versions.first.id,
                                                      :status => 'successful', :task_id => task.id, :user => User.first)

      assert history.humanized_action.is_a?(String)
    end
  end
end
