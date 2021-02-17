require 'katello_test_helper'

class RegistrationCommandsControllerTest < ActionController::TestCase
  def setup
    @tax_params = { organization: taxonomies(:organization1).id, location: taxonomies(:location1).id }

    setup_controller_defaults(false)
    setup_foreman_routes
    login_user(User.find(users(:admin).id))
  end

  def test_one_key
    post :create, params: { activation_key: ' key1 ' }.merge(@tax_params)
    assert_includes(assigns(:command), 'activation_key=key1')
  end

  def test_two_keys
    post :create, params: { activation_key: ' key1 , key2 , ' }.merge(@tax_params)
    assert_includes(assigns(:command), 'activation_key=key1%2Ckey2')
  end

  def test_formatting1
    post :create, params: { activation_key: ' , ,,key1, , key2, , ,,,  , ,' }.merge(@tax_params)
    assert_includes(assigns(:command), 'activation_key=key1%2Ckey2')
  end

  def test_key_with_space
    post :create, params: { activation_key: ' key1 with space ' }.merge(@tax_params)
    assert_includes(assigns(:command), 'activation_key=key1+with+space')
  end

  def test_keys_with_spaces
    post :create, params: { activation_key: ' key1 with space , key2 with space ' }.merge(@tax_params)
    assert_includes(assigns(:command), 'activation_key=key1+with+space%2Ckey2+with+space')
  end

  def test_formatting_keys
    post :create, params: { activation_key: ' key1 with space , key2 with space ,, ,, , ' }.merge(@tax_params)
    assert_includes(assigns(:command), 'activation_key=key1+with+space%2Ckey2+with+space')
  end

  def test_empty_key
    post :create, params: { activation_key: '' }.merge(@tax_params)
    refute_includes(assigns(:command), 'activation_key=')
  end

  def test_nil_key
    post :create, params: @tax_params
    refute_includes(assigns(:command), 'activation_key=')
  end
end
