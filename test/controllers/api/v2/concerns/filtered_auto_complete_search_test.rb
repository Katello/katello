require 'katello_test_helper'

class AutoCompleteSearchTest < ActionController::TestCase
  # Chosen at random as a representative of the controllers supporting Katello's autocompletion
  tests ::Katello::Api::V2::ProductsController

  def setup
    setup_controller_defaults_api
  end

  test "only suggests options the user is allowed to see" do
    user = users(:one)
    org = user.organizations.first
    product1 = FactoryBot.create(:katello_product, :with_provider, organization_id: org.id)
    _product2 = FactoryBot.create(:katello_product, :with_provider, organization_id: org.id)
    setup_user('view', 'products', "name = \"#{product1.name}\"")

    get :auto_complete_search, session: set_session_user(:one), params: { search: "name =", organization_id: org.id }
    assert_predicate response, :successful?
    suggestions = ActiveSupport::JSON.decode(response.body)
    assert_equal 1, suggestions.length
    assert_equal suggestions.first['part'], "name = \"#{product1.name}\""
  end
end
