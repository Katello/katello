require 'katello_test_helper'

module Katello
  class ContentViewContainerPathValidatorTest < ActiveSupport::TestCase
    include Dynflow::Testing

    Validator = Validators::ContentViewContainerPathValidator
    Paths = Validators::ContainerPathOverlapValidator
    Reference = Struct.new(:id, :path, :repository, keyword_init: true)

    def setup
      @organization = Organization.new(name: 'Example', label: 'example')
      @product = Katello::Product.new(name: 'Product', label: 'product', organization: @organization)
      @source_view = Katello::ContentView.new(name: 'Component', label: 'component', organization: @organization, default: false)
      @view = Katello::ContentView.new(name: 'Composite', label: 'composite', organization: @organization, default: false)
      @source_version = Katello::ContentViewVersion.new(content_view: @source_view, major: 1, minor: 0)
      @version = Katello::ContentViewVersion.new(content_view: @view, major: 7, minor: 2)
      @dev = Katello::KTEnvironment.new(name: 'Dev', label: 'dev', organization: @organization)
      @qa = Katello::KTEnvironment.new(name: 'QA', label: 'qa', organization: @organization)
      @view.stubs(:get_repo_clone).returns([])
      @source = source('image', 'team/image')
    end

    def source(label, upstream, content_type: 'docker')
      root = Katello::RootRepository.new(name: label, label: label, product: @product,
                                         content_type: content_type, docker_upstream_name: upstream)
      Katello::Repository.new(root: root, environment: @dev, content_view_version: @source_version)
    end

    def proposed(sources = [@source], environments = [@qa], include_archive: false)
      Validator.candidates(version: @version, sources: sources, environments: environments, include_archive: include_archive)
    end

    test 'render target view version and environment without mutating the component source' do
      @qa.registry_name_pattern = '<%= content_view.label %>/<%= content_view_version.version %>/<%= lifecycle_environment.label %>/<%= repository.docker_upstream_name %>'
      candidate = proposed.first
      assert_equal 'composite/7_2/qa/team/image', candidate.path
      assert_same @source, candidate.repository
      assert_nil candidate.reference_id
      assert_same @source_version, @source.content_view_version
      assert_same @dev, @source.environment
    end

    test 'archive uses target version and no environment pattern' do
      @qa.registry_name_pattern = 'custom/path'
      candidates = proposed([@source], [@qa], include_archive: true)
      assert_equal ['custom/path', 'example/composite/7_2/product/image'], candidates.map(&:path)
      assert(candidates.all? { |candidate| candidate.reference_id.nil? })
    end

    test 'only the actual destination clone reference is excluded' do
      clone = mock('destination clone')
      clone.stubs(:id).returns(42)
      reference = Reference.new(id: 101, path: 'team/image', repository: clone)
      other_clone_reference = Reference.new(id: 102, path: 'team/image/old', repository: @source)
      @qa.registry_name_pattern = '<%= repository.docker_upstream_name %>'
      @view.stubs(:get_repo_clone).with(@qa, @source).returns([clone])
      Validator.stubs(:existing_reference_ids).with([42]).returns(42 => reference.id)
      candidate = proposed.first
      assert_same clone, candidate.repository
      assert_equal 101, candidate.reference_id
      assert_equal([102], Paths.conflicts(candidates: [candidate], references: [reference, other_clone_reference]).map { |conflict| conflict.other.reference_id })
    end

    test 'other environments do not inherit an existing clone reference' do
      clone = mock('destination clone', id: 42)
      reference = Reference.new(id: 101, path: 'existing', repository: clone)
      @view.stubs(:get_repo_clone).with(@dev, @source).returns([clone])
      @view.stubs(:get_repo_clone).with(@qa, @source).returns([])
      Validator.stubs(:existing_reference_ids).with([42]).returns(42 => reference.id)
      candidates = proposed([@source], [@dev, @qa], include_archive: true)
      assert_equal [101, nil, nil], candidates.map(&:reference_id)
      assert_equal [clone, @source, @source], candidates.map(&:repository)
    end

    test 'all actual targets are checked together including slash segment overlaps' do
      @dev.registry_name_pattern = 'team'
      @qa.registry_name_pattern = 'team/image'
      candidates = proposed([@source], [@dev, @qa])
      assert_equal 1, Paths.conflicts(candidates: candidates, references: []).size
      @qa.registry_name_pattern = 'teamwork/image'
      assert_empty Paths.conflicts(candidates: proposed([@source], [@dev, @qa]), references: [])
    end

    test 'multiple sources use projected target paths and empty or non-container sources are ignored' do
      @qa.registry_name_pattern = '<%= repository.docker_upstream_name %>'
      second = source('image2', 'team/image/child')
      rpm = source('rpm', nil, content_type: 'yum')
      assert_empty proposed([], [@qa])
      assert_empty proposed([rpm], [@qa])
      candidates = proposed([@source, second, rpm], [@qa])
      assert_equal ['team/image', 'team/image/child'], candidates.map(&:path)
      assert_equal 1, Paths.conflicts(candidates: candidates, references: []).size
    end

    test 'an unknown user sees a redacted message for a current conflict' do
      @qa.registry_name_pattern = 'team/image'
      other = source('hidden', 'other')
      references = [Reference.new(id: 200, path: 'team', repository: other)]
      messages = Paths.messages(candidates: proposed, organization: @organization, user: nil, references: references)
      assert_equal 1, messages.size
      assert_includes messages.first, 'administrator'
      assert_not_includes messages.first, 'team'
      assert_not_includes messages.first, 'hidden'
    end

    test 'current other clone paths are compared even for a new clone' do
      @qa.registry_name_pattern = 'team/image'
      existing = Reference.new(id: 200, path: 'team', repository: @source)
      candidate = proposed.first
      assert_nil candidate.reference_id
      assert_equal([200], Paths.conflicts(candidates: [candidate], references: [existing]).map { |conflict| conflict.other.reference_id })
    end

    test 'validation raises an HTTP conflict with the central privacy-safe message' do
      @qa.registry_name_pattern = '<%= repository.docker_upstream_name %>'
      second = source('image2', 'team/image/child')
      expectation = Paths.stubs(:messages).with do |args|
        assert_equal @organization, args[:organization]
        assert_nil args[:user]
        assert_equal ['team/image', 'team/image/child'], args[:candidates].map(&:path)
        true
      end
      expectation.returns(['A distribution path overlaps. Contact an administrator.'])
      error = assert_raises(Katello::HttpErrors::Conflict) do
        Validator.validate!(version: @version, sources: [@source, second], environments: [@qa], user: nil)
      end
      assert_equal 'A distribution path overlaps. Contact an administrator.', error.message
      assert_not_includes error.message, 'team/image'
    end

    test 'validation checks true projected names before the central checker' do
      @qa.registry_name_pattern = '<%= repository.docker_upstream_name %>'
      second = source('image2', 'another/image')
      expectation = Paths.expects(:messages).with do |args|
        assert_equal ['team/image', 'another/image'], args[:candidates].map(&:path)
        true
      end
      expectation.returns([])
      Validator.validate!(version: @version, sources: [@source, second], environments: [@qa], user: nil)
    end

    test 'invalid projected names raise a privacy-safe conflict before overlap checking' do
      secret = source('secret-repository', 'secretparent/secretchild')
      Paths.expects(:messages).never
      ['secretparent//secretchild', '/', 'secretparent/secretchild/'].each do |invalid_path|
        @qa.registry_name_pattern = invalid_path
        error = assert_raises(Katello::HttpErrors::Conflict) do
          Validator.validate!(version: @version, sources: [secret], environments: [@qa], user: nil)
        end
        assert_includes error.message, 'invalid'
        assert_includes error.message, 'registry name pattern'
        assert_includes error.message, 'administrator'
        assert_not_includes error.message, invalid_path
        assert_not_includes error.message, secret.name
        assert_not_includes error.message, 'secretparent'
        assert_not_includes error.message, 'secretchild'
      end
    end

    test 'nil upstream name that renders blank raises a conflict before overlap checking' do
      @qa.registry_name_pattern = '<%= repository.docker_upstream_name %>'
      missing_upstream = source('missing', nil)
      missing_upstream.environment = @qa
      assert_equal '', Katello::Repository.safe_render_container_name(missing_upstream)
      Paths.expects(:messages).never
      error = assert_raises(Katello::HttpErrors::Conflict) do
        Validator.validate!(version: @version, sources: [@source, missing_upstream], environments: [@qa], user: nil)
      end
      assert_includes error.message, 'invalid'
      assert_not_includes error.message, missing_upstream.name
    end

    test 'nil projected archive path raises a conflict before overlap checking' do
      Katello::Repository.stubs(:safe_render_container_name).returns(nil)
      Paths.expects(:messages).never
      error = assert_raises(Katello::HttpErrors::Conflict) do
        Validator.validate!(version: @version, sources: [@source], environments: [], include_archive: true, user: nil)
      end
      assert_includes error.message, 'invalid'
    end

    test 'validation skips central checker when nothing will be distributed' do
      Paths.expects(:messages).never
      Validator.validate!(version: @version, sources: [@source], environments: [], user: nil)
    end

    test 'publish checks projected destinations before saving the version or history' do
      action = create_action(Actions::Katello::ContentView::Publish)
      action.stubs(:action_subject)
      action.stubs(:include_other_components).returns([@source_version])
      action.stubs(:find_environments).with([123]).returns([@qa])
      @organization.stubs(:library).returns(@dev)
      @view.stubs(:check_ready_to_publish!)
      @view.stubs(:publish_repositories).with([@source_version]).yields([@source, source('component2', 'team/second')])
      @view.expects(:create_new_version).never
      Katello::ContentViewHistory.expects(:create!).never
      Katello::Util::CandlepinRepositoryChecker.stubs(:check_repositories_for_publish!)
      Setting.stubs(:[]).with(:distribute_archived_cvv).returns(true)
      expectation = Validator.expects(:validate!).with do |args|
        assert_equal @view, args[:version].content_view
        assert_equal '3.4', args[:version].version
        assert_equal [@source], args[:sources]
        assert_equal [@dev, @qa], args[:environments]
        assert args[:include_archive]
        assert_equal User.current, args[:user]
        true
      end
      expectation.raises(Katello::HttpErrors::Conflict, 'overlap')
      assert_raises(Katello::HttpErrors::Conflict) do
        action.plan(@view, '', major: 3, minor: 4, override_components: [@source_version], environment_ids: [123])
      end
    end

    test 'publish skip promotion uses next version and only requested environments' do
      action = create_action(Actions::Katello::ContentView::Publish)
      action.stubs(:action_subject)
      action.stubs(:include_other_components).returns(nil)
      action.stubs(:find_environments).with([123]).returns([@qa])
      @organization.stubs(:library).returns(@dev)
      @view.stubs(:check_ready_to_publish!)
      @view.stubs(:publish_repositories).with(nil).yields([@source])
      @view.stubs(:next_version).returns(9)
      @view.expects(:create_new_version).never
      Katello::Util::CandlepinRepositoryChecker.stubs(:check_repositories_for_publish!)
      Setting.stubs(:[]).with(:distribute_archived_cvv).returns(false)
      expectation = Validator.expects(:validate!).with do |args|
        assert_equal '9.0', args[:version].version
        assert_equal [@qa], args[:environments]
        assert_not args[:include_archive]
        true
      end
      expectation.raises(Katello::HttpErrors::Conflict, 'overlap')
      assert_raises(Katello::HttpErrors::Conflict) do
        action.plan(@view, '', skip_promotion: true, environment_ids: [123])
      end
    end

    test 'promote checks archived sources for all environments before planning or history' do
      action = create_action(Actions::Katello::ContentView::Promote)
      action.stubs(:action_subject)
      action.expects(:plan_self).never
      @version.stubs(:check_ready_to_promote!)
      @version.stubs(:promotable?).returns(true)
      @version.stubs(:archived_repos).returns([@source])
      Katello::Util::CandlepinRepositoryChecker.stubs(:check_repositories_for_promote!)
      Katello::ContentViewHistory.expects(:create!).never
      expectation = Validator.expects(:validate!).with do |args|
        assert_same @version, args[:version]
        assert_equal [@source], args[:sources]
        assert_equal [@dev, @qa], args[:environments]
        assert_not args[:include_archive]
        true
      end
      expectation.raises(Katello::HttpErrors::Conflict, 'overlap')
      assert_raises(Katello::HttpErrors::Conflict) { action.plan(@version, [@dev, @qa]) }
    end
  end
end
