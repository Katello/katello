require 'katello_test_helper'

module Katello
  class RelationPresenterTest < ActiveSupport::TestCase
    def test_presenter
      presenter = RelationPresenter.new(ContentView)

      assert_equal ContentView, presenter.relation
    end
  end
end
