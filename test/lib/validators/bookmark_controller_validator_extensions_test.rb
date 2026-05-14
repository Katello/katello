require 'katello_test_helper'

module Katello
  class BookmarkControllerValidatorExtensionsTest < ActiveSupport::TestCase
    Katello::Concerns::BookmarkControllerValidatorExtensions::KATELLO_CONTROLLERS.each do |controller|
      test "#{controller} should be a valid bookmark controller" do
        bookmark = FactoryBot.build_stubbed(:bookmark, :name => "#{controller} bookmark",
                                                       :controller => controller,
                                                       :query => 'search query',
                                                       :public => true)
        assert bookmark.valid?, "#{controller} should be a valid bookmark controller, errors: #{bookmark.errors.full_messages}"
      end
    end
  end
end
