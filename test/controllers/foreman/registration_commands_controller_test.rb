require 'katello_test_helper'

class Api::V2::RegistrationCommandsControllerTest < ActionController::TestCase
  def setup
    setup_controller_defaults(false)
    setup_foreman_routes
    login_user(User.find(users(:admin).id))
  end

  def test_ack_one_key
    post :create, params: { activation_key: ' key1 ' }
    assert_includes(JSON.parse(@response.body)['registration_command'], 'activation_keys=key1')
    refute_includes(JSON.parse(@response.body)['registration_command'], 'activation_key=key1')
  end

  def test_ack_two_keys
    post :create, params: { activation_key: ' key1 , key2 , ' }
    assert_includes(JSON.parse(@response.body)['registration_command'], 'activation_keys=key1%2Ckey2')
  end

  def test_ack_formatting1
    post :create, params: { activation_key: ' , ,,key1, , key2, , ,,,  , ,' }
    assert_includes(JSON.parse(@response.body)['registration_command'], 'activation_keys=key1%2Ckey2')
  end

  def test_ack_key_with_space
    post :create, params: { activation_key: ' key1 with space ' }
    assert_includes(JSON.parse(@response.body)['registration_command'], 'activation_keys=key1+with+space')
  end

  def test_ack_keys_with_spaces
    post :create, params: { activation_key: ' key1 with space , key2 with space ' }
    assert_includes(JSON.parse(@response.body)['registration_command'], 'activation_keys=key1+with+space%2Ckey2+with+space')
  end

  def test_ack_formatting_keys
    post :create, params: { activation_key: ' key1 with space , key2 with space ,, ,, , ' }
    assert_includes(JSON.parse(@response.body)['registration_command'], 'activation_keys=key1+with+space%2Ckey2+with+space')
  end

  def test_ack_empty_key
    post :create, params: { activation_key: '' }
    refute_includes(JSON.parse(@response.body)['registration_command'], 'activation_keys=')
    refute_includes(JSON.parse(@response.body)['registration_command'], 'activation_key=')
  end

  def test_ack_nil_key
    post :create
    refute_includes(JSON.parse(@response.body)['registration_command'], 'activation_keys=')
    refute_includes(JSON.parse(@response.body)['registration_command'], 'activation_key=')
  end

  def test_ack_array
    post :create, params: { activation_key: ['key1', 'key2']}
    assert_includes(JSON.parse(@response.body)['registration_command'], 'activation_keys=key1%2Ckey2')
  end

  def test_acks_array
    post :create, params: { activation_keys: ['key1', 'key2']}
    assert_includes(JSON.parse(@response.body)['registration_command'], 'activation_keys=key1%2Ckey2')
  end

  def test_with_ignore_subman_errors
    post :create, params: { ignore_subman_errors: true }
    assert_includes(JSON.parse(@response.body)['registration_command'], 'ignore_subman_errors=true')
  end

  def test_with_lifecycle_environment_id
    post :create, params: { lifecycle_environment_id: 23 }
    assert_includes(JSON.parse(@response.body)['registration_command'], 'lifecycle_environment_id=23')
  end
end
