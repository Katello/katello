require 'katello_test_helper'

module Katello
  class RepositoryPresenterTest < ActiveSupport::TestCase
    def setup
      @presenter = RepositoryPresenter.new(katello_repositories(:fedora_17_x86_64))
    end

    def test_content_view_environments
      content_view_environments = @presenter.content_view_environments

      assert_equal content_view_environments.length, 4
    end
  end
end
