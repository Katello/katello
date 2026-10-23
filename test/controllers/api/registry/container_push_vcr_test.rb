require 'katello_test_helper'
require 'digest'

module Katello
  class ContainerPushVcrTest < ActionController::TestCase
    tests Api::Registry::RegistryProxiesController
    include Katello::Pulp3Support

    def setup
      @registered_mime_types = []
      {octet_stream: "application/octet-stream", docker_manifest: "application/vnd.docker.distribution.manifest.v2+json"}.each do |name, type|
        next if Mime::Type.lookup(type).symbol
        Mime::Type.register(type, name)
        @registered_mime_types << name
      end
      User.current = users(:admin)
      setup_controller_defaults_api
      # Exercise the push controller and Pulp; authentication has separate controller coverage.
      @controller.stubs(:registry_authorize).returns(true)
      @controller.stubs(:container_registry_smart_proxy_authenticated?).returns(false)
      @primary = SmartProxy.pulp_primary
      @repo = katello_repositories(:busybox)
      @product = @repo.product
      @api = @repo.backend_service(@primary).api
      @published = nil
    end

    def teardown
      ensure_creatable(@published, @primary) if @published
      ensure_creatable(@repo, @primary)
      @registered_mime_types.each { |name| Mime::Type.unregister(name) }
    end

    def test_initial_and_repeat_push_by_labels
      configure_push('label')
      assert_initial_and_repeat_push
    end

    def test_initial_and_repeat_push_by_ids
      configure_push('id')
      assert_initial_and_repeat_push
    end

    private

    def configure_push(format)
      name = 'busybox'
      @path = if format == 'id'
                "id/#{@product.organization_id}/#{@product.id}/#{name}"
              else
                "#{@product.organization.label.downcase}/#{@product.label.downcase}/#{name}"
              end
      @repo.root.update_columns(is_container_push: true, container_push_name: @path, container_push_name_format: format, url: nil)
      @repo.update!(container_repository_name: @path, pulp_id: @path)
      # The Katello repository exists, but Pulp must create its backend on the first push.
      ensure_creatable(@repo, @primary)
      @repo.root.repository_references.delete_all
      @repo.distribution_references.delete_all
      @repo.update!(version_href: nil, version_prn: nil)
    end

    def registry_request(action, **options)
      User.current = users(:admin)
      content_type = request.headers['Content-Type']
      setup_controller_request_and_response
      request.headers['Content-Type'] = content_type if content_type
      query = options.fetch(:params, {}).except(:repository, :uuid, :tag)
      request.env['QUERY_STRING'] = query.to_query
      process(action, **options)
    end

    def fixture_bytes(name)
      File.binread(Katello::Engine.root.join('test/fixtures/files/container_push', name))
    end

    def manifest_digest(version)
      "sha256:#{Digest::SHA256.hexdigest(fixture_bytes("manifest_v#{version}.json"))}"
    end

    def push_image(version)
      ["layer.tar.gz", "config_v#{version}.json"].each do |name|
        blob = fixture_bytes(name)
        registry_request :start_upload_blob, method: :post, params: {repository: @path}, body: ''
        assert_response :accepted
        location = URI.parse(response.headers['Location'] || response.headers.fetch('location'))
        uuid = location.path.split('/').last
        # Preserve the registry query parameters (including upload state) returned by Pulp.
        query = Rack::Utils.parse_query(location.query)
        request.headers['Content-Type'] = 'application/octet-stream'
        registry_request :upload_blob, method: :patch, params: query.merge(repository: @path, uuid: uuid), body: blob
        assert_response :accepted
        query['digest'] = "sha256:#{Digest::SHA256.hexdigest(blob)}"
        registry_request :finish_upload_blob, method: :put, params: query.merge(repository: @path, uuid: uuid), body: ''
        assert_response :created
      end
      request.headers['Content-Type'] = 'application/vnd.docker.distribution.manifest.v2+json'
      registry_request :push_manifest, method: :put, params: {repository: @path, tag: 'v1'}, body: fixture_bytes("manifest_v#{version}.json")
      assert_response :created
      @repo.reload
    end

    def assert_initial_and_repeat_push
      assert_empty @api.repositories_api.list(name: @path).results
      push_image(1)
      first_version = @repo.version_href
      href = @repo.root.repository_references.sole.repository_href
      assert_includes href, '/container/container/'
      assert_equal ['v1'], @repo.docker_tags.pluck(:name)
      assert_equal manifest_digest(1), @repo.docker_tags.find_by!(name: 'v1').docker_manifest.digest
      push_image(2)
      assert_equal href, @repo.root.repository_references.sole.repository_href
      refute_equal first_version, @repo.version_href
      assert_equal ['v1'], @repo.docker_tags.pluck(:name)
      assert_equal manifest_digest(2), @repo.docker_tags.find_by!(name: 'v1').docker_manifest.digest
    end

    def assert_published_snapshot
      User.current = users(:admin)
      @published = katello_repositories(:busybox_dev)
      @published.update!(container_repository_name: "#{@path}-published", pulp_id: 'container-push-vcr-published')
      create_repo(@published, @primary)
      # Run the version reference and metadata stages used by content-view publication.
      # Candlepin environment creation is unrelated to container content and is not needed here.
      task = ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::CopyAllUnits,
                                   @published, @primary, [@repo])
      assert_equal 'success', task.result
      @published.reload.index_content(full_index: true)
      ForemanTasks.sync_task(::Actions::Katello::Repository::MetadataGenerate, @published)
      assert_includes @published.version_href, '/container/container/'
      assert_equal @repo.version_href, @published.version_href
      distribution = @published.backend_service(@primary).read_distribution
      assert_equal @published.version_href, distribution.repository_version
      assert_nil distribution.repository
      push_image(2)
      assert_equal manifest_digest(2), @repo.docker_tags.find_by!(name: 'v1').docker_manifest.digest
      assert_equal manifest_digest(1), @published.docker_tags.find_by!(name: 'v1').docker_manifest.digest
      registry_request :pull_manifest, method: :get, params: {repository: @published.container_repository_name, tag: 'v1'}
      assert_response :success
      assert_equal manifest_digest(1), "sha256:#{Digest::SHA256.hexdigest(response.body)}"
    end
  end
end
