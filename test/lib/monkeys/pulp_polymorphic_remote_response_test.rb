require 'katello_test_helper'

class PulpPolymorphicRemoteResponseTest < ActiveSupport::TestCase
  def setup
    @rpm_config = PulpRpmClient::Configuration.default
    @rpm_config.host = 'localhost:24817'

    @ansible_config = PulpAnsibleClient::Configuration.default
    @ansible_config.host = 'localhost:24817'

    @container_config = PulpContainerClient::Configuration.default
    @container_config.host = 'localhost:24817'

    @ostree_config = PulpOstreeClient::Configuration.default
    @ostree_config.host = 'localhost:24817'
  end

  test "RPM RemotesRpmApi partial_update returns AsyncOperationResponse" do
    task_json = {
      task: '/pulp/api/v3/tasks/12345678-1234-1234-1234-123456789012/',
    }.to_json

    stub_request(:patch, %r{.*remotes/rpm/rpm.*})
      .to_return(status: 202, body: task_json, headers: {'Content-Type' => 'application/json'})

    api = PulpRpmClient::RemotesRpmApi.new(PulpRpmClient::ApiClient.new(@rpm_config))
    patched_remote = PulpRpmClient::PatchedrpmRpmRemote.new(name: 'test-remote')

    result = api.partial_update('/pulp/api/v3/remotes/rpm/rpm/test/', patched_remote)

    assert_not_nil result, "Expected AsyncOperationResponse"
    assert_equal '/pulp/api/v3/tasks/12345678-1234-1234-1234-123456789012/', result.task
    assert_kind_of PulpRpmClient::AsyncOperationResponse, result
  end

  test "RPM RemotesRpmApi update returns AsyncOperationResponse" do
    task_json = {
      task: '/pulp/api/v3/tasks/87654321-4321-4321-4321-210987654321/',
    }.to_json

    stub_request(:put, %r{.*remotes/rpm/rpm.*})
      .to_return(status: 202, body: task_json, headers: {'Content-Type' => 'application/json'})

    api = PulpRpmClient::RemotesRpmApi.new(PulpRpmClient::ApiClient.new(@rpm_config))
    rpm_remote = PulpRpmClient::RpmRpmRemote.new(name: 'test-remote', url: 'http://example.com')

    result = api.update('/pulp/api/v3/remotes/rpm/rpm/test/', rpm_remote)

    assert_not_nil result
    assert_equal '/pulp/api/v3/tasks/87654321-4321-4321-4321-210987654321/', result.task
    assert_kind_of PulpRpmClient::AsyncOperationResponse, result
  end

  test "RPM RemotesUlnApi partial_update returns AsyncOperationResponse" do
    task_json = {
      task: '/pulp/api/v3/tasks/11111111-1111-1111-1111-111111111111/',
    }.to_json

    stub_request(:patch, %r{.*remotes/rpm/uln.*})
      .to_return(status: 202, body: task_json, headers: {'Content-Type' => 'application/json'})

    api = PulpRpmClient::RemotesUlnApi.new(PulpRpmClient::ApiClient.new(@rpm_config))
    patched_remote = PulpRpmClient::PatchedrpmUlnRemote.new(name: 'test-uln-remote')

    result = api.partial_update('/pulp/api/v3/remotes/rpm/uln/test/', patched_remote)

    assert_not_nil result
    assert_equal '/pulp/api/v3/tasks/11111111-1111-1111-1111-111111111111/', result.task
    assert_kind_of PulpRpmClient::AsyncOperationResponse, result
  end

  test "Ansible RemotesCollectionApi partial_update returns AsyncOperationResponse" do
    task_json = {
      task: '/pulp/api/v3/tasks/22222222-2222-2222-2222-222222222222/',
    }.to_json

    stub_request(:patch, %r{.*remotes/ansible/collection.*})
      .to_return(status: 202, body: task_json, headers: {'Content-Type' => 'application/json'})

    api = PulpAnsibleClient::RemotesCollectionApi.new(PulpAnsibleClient::ApiClient.new(@ansible_config))
    patched_remote = PulpAnsibleClient::PatchedansibleCollectionRemote.new(name: 'test-collection')

    result = api.partial_update('/pulp/api/v3/remotes/ansible/collection/test/', patched_remote)

    assert_not_nil result
    assert_equal '/pulp/api/v3/tasks/22222222-2222-2222-2222-222222222222/', result.task
    assert_kind_of PulpAnsibleClient::AsyncOperationResponse, result
  end

  test "Ansible RemotesGitApi partial_update returns AsyncOperationResponse" do
    task_json = {
      task: '/pulp/api/v3/tasks/33333333-3333-3333-3333-333333333333/',
    }.to_json

    stub_request(:patch, %r{.*remotes/ansible/git.*})
      .to_return(status: 202, body: task_json, headers: {'Content-Type' => 'application/json'})

    api = PulpAnsibleClient::RemotesGitApi.new(PulpAnsibleClient::ApiClient.new(@ansible_config))
    patched_remote = PulpAnsibleClient::PatchedansibleGitRemote.new(name: 'test-git')

    result = api.partial_update('/pulp/api/v3/remotes/ansible/git/test/', patched_remote)

    assert_not_nil result
    assert_equal '/pulp/api/v3/tasks/33333333-3333-3333-3333-333333333333/', result.task
    assert_kind_of PulpAnsibleClient::AsyncOperationResponse, result
  end

  test "Ansible RemotesRoleApi partial_update returns AsyncOperationResponse" do
    task_json = {
      task: '/pulp/api/v3/tasks/44444444-4444-4444-4444-444444444444/',
    }.to_json

    stub_request(:patch, %r{.*remotes/ansible/role.*})
      .to_return(status: 202, body: task_json, headers: {'Content-Type' => 'application/json'})

    api = PulpAnsibleClient::RemotesRoleApi.new(PulpAnsibleClient::ApiClient.new(@ansible_config))
    patched_remote = PulpAnsibleClient::PatchedansibleRoleRemote.new(name: 'test-role')

    result = api.partial_update('/pulp/api/v3/remotes/ansible/role/test/', patched_remote)

    assert_not_nil result
    assert_equal '/pulp/api/v3/tasks/44444444-4444-4444-4444-444444444444/', result.task
    assert_kind_of PulpAnsibleClient::AsyncOperationResponse, result
  end

  test "Container RemotesContainerApi partial_update returns AsyncOperationResponse" do
    task_json = {
      task: '/pulp/api/v3/tasks/55555555-5555-5555-5555-555555555555/',
    }.to_json

    stub_request(:patch, %r{.*remotes/container/container.*})
      .to_return(status: 202, body: task_json, headers: {'Content-Type' => 'application/json'})

    api = PulpContainerClient::RemotesContainerApi.new(PulpContainerClient::ApiClient.new(@container_config))
    patched_remote = PulpContainerClient::PatchedcontainerContainerRemote.new(name: 'test-container')

    result = api.partial_update('/pulp/api/v3/remotes/container/container/test/', patched_remote)

    assert_not_nil result
    assert_equal '/pulp/api/v3/tasks/55555555-5555-5555-5555-555555555555/', result.task
    assert_kind_of PulpContainerClient::AsyncOperationResponse, result
  end

  test "Container RemotesPullThroughApi partial_update returns AsyncOperationResponse" do
    task_json = {
      task: '/pulp/api/v3/tasks/66666666-6666-6666-6666-666666666666/',
    }.to_json

    stub_request(:patch, %r{.*remotes/container/pull-through.*})
      .to_return(status: 202, body: task_json, headers: {'Content-Type' => 'application/json'})

    api = PulpContainerClient::RemotesPullThroughApi.new(PulpContainerClient::ApiClient.new(@container_config))
    patched_remote = PulpContainerClient::PatchedcontainerContainerPullThroughRemote.new(name: 'test-pullthrough')

    result = api.partial_update('/pulp/api/v3/remotes/container/pull-through/test/', patched_remote)

    assert_not_nil result
    assert_equal '/pulp/api/v3/tasks/66666666-6666-6666-6666-666666666666/', result.task
    assert_kind_of PulpContainerClient::AsyncOperationResponse, result
  end

  test "OSTree RemotesOstreeApi partial_update returns AsyncOperationResponse" do
    task_json = {
      task: '/pulp/api/v3/tasks/77777777-7777-7777-7777-777777777777/',
    }.to_json

    stub_request(:patch, %r{.*remotes/ostree/ostree.*})
      .to_return(status: 202, body: task_json, headers: {'Content-Type' => 'application/json'})

    api = PulpOstreeClient::RemotesOstreeApi.new(PulpOstreeClient::ApiClient.new(@ostree_config))
    patched_remote = PulpOstreeClient::PatchedostreeOstreeRemote.new(name: 'test-ostree')

    result = api.partial_update('/pulp/api/v3/remotes/ostree/ostree/test/', patched_remote)

    assert_not_nil result
    assert_equal '/pulp/api/v3/tasks/77777777-7777-7777-7777-777777777777/', result.task
    assert_kind_of PulpOstreeClient::AsyncOperationResponse, result
  end

  test "Patch preserves original method arguments" do
    # Test that patching doesn't break argument passing
    task_json = {
      task: '/pulp/api/v3/tasks/99999999-9999-9999-9999-999999999999/',
    }.to_json

    stub_request(:patch, %r{.*remotes/rpm/rpm.*})
      .with(headers: {'X-Custom-Header' => 'test-value'})
      .to_return(status: 202, body: task_json, headers: {'Content-Type' => 'application/json'})

    api = PulpRpmClient::RemotesRpmApi.new(PulpRpmClient::ApiClient.new(@rpm_config))
    patched_remote = PulpRpmClient::PatchedrpmRpmRemote.new(name: 'test-remote')

    # Pass custom options to ensure they're preserved
    result = api.partial_update(
      '/pulp/api/v3/remotes/rpm/rpm/test/',
      patched_remote,
      { header_params: { 'X-Custom-Header' => 'test-value' } }
    )

    assert_not_nil result
    assert_equal '/pulp/api/v3/tasks/99999999-9999-9999-9999-999999999999/', result.task

    # Verify the custom header was actually sent in the request
    assert_requested(:patch, %r{remotes/rpm/rpm}, headers: {'X-Custom-Header' => 'test-value'})
  end
end
