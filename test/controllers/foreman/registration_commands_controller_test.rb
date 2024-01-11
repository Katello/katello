require 'katello_test_helper'

class Api::V2::RegistrationCommandsControllerTest < ActionController::TestCase
  def setup
    setup_controller_defaults(false)
    setup_foreman_routes
    login_user(User.find(users(:admin).id))
  end

  def test_ack_one_key
    post :create, params: { activation_key: ' key1 ' }

    assert_response :success
    assert_includes(JSON.parse(@response.body)['registration_command'], 'activation_keys=key1')
    refute_includes(JSON.parse(@response.body)['registration_command'], 'activation_key=key1')
  end

  def test_ack_two_keys
    post :create, params: { activation_key: ' key1 , key2 , ' }

    assert_response :success
    assert_includes(JSON.parse(@response.body)['registration_command'], 'activation_keys=key1%2Ckey2')
  end

  def test_ack_formatting
    post :create, params: { activation_key: ' , ,,key1, , key2, , ,,,  , ,' }

    assert_response :success
    assert_includes(JSON.parse(@response.body)['registration_command'], 'activation_keys=key1%2Ckey2')
  end

  def test_ack_key_with_space
    post :create, params: { activation_key: ' key1 with space ' }

    assert_response :success
    assert_includes(JSON.parse(@response.body)['registration_command'], 'activation_keys=key1+with+space')
  end

  def test_ack_keys_with_spaces
    post :create, params: { activation_key: ' key1 with space , key2 with space ' }

    assert_response :success
    assert_includes(JSON.parse(@response.body)['registration_command'], 'activation_keys=key1+with+space%2Ckey2+with+space')
  end

  def test_ack_formatting_keys
    post :create, params: { activation_key: ' key1 with space , key2 with space ,, ,, , ' }

    assert_response :success
    assert_includes(JSON.parse(@response.body)['registration_command'], 'activation_keys=key1+with+space%2Ckey2+with+space')
  end

  def test_ack_empty_key
    post :create, params: { activation_key: '' }
    assert_response :unprocessable_entity
  end

  def test_ack_nil_key
    post :create
    assert_response :unprocessable_entity
  end

  def test_acks_array
    post :create, params: { activation_keys: ['key1', 'key2'] }

    assert_response :success
    assert_includes(JSON.parse(@response.body)['registration_command'], 'activation_keys=key1%2Ckey2')
  end

  def test_acks_empty_array
    post :create, params: { activation_keys: [] }
    assert_response :unprocessable_entity
  end

  def test_ack_and_acks
    post :create, params: { activation_key: 'key1, key2', activation_keys: ['key3', 'key4'] }

    assert_response :success
    assert_includes(JSON.parse(@response.body)['registration_command'], 'activation_keys=key3%2Ckey4')
  end

  def test_with_ignore_subman_errors
    post :create, params: { ignore_subman_errors: true, activation_keys: ['key1'] }

    assert_response :success
    assert_includes(JSON.parse(@response.body)['registration_command'], 'ignore_subman_errors=true')
  end

  def test_hostgroup_with_ack
    hostgroup = FactoryBot.create(:hostgroup)
    FactoryBot.create(:hostgroup_parameter, hostgroup: hostgroup, name: 'kt_activation_keys', value: 'key1')
    hostgroup.reload

    post :create, params: { hostgroup_id: hostgroup.id }
    assert_response :success
  end

  def test_hostgroup_without_ack
    hostgroup = FactoryBot.create(:hostgroup)
    post :create, params: { hostgroup_id: hostgroup.id }

    assert_response :unprocessable_entity
  end
end
