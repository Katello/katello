require 'katello_test_helper'

module Katello
  class BaseTemplateScopeExtensionsTest < ActiveSupport::TestCase
    def setup
      @host = hosts(:one)
      @errata = katello_errata(:security)
      @bugfix = katello_errata(:bugfix)
      @user = User.first
    end

    def test_errata
      source = ::Foreman::Renderer::Source::String.new(
        name: 'Parameter',
        content: "<%= errata('#{@errata.errata_id}')['id'] %>"
      )
      scope = ::Foreman::Renderer.get_scope
      id = ::Foreman::Renderer.render(source, scope)

      refute_empty id
      assert_equal @errata.id.to_s, id
    end

    def test_load_errata_applications_structure
      create_errata_application(@host, [@errata])
      scope = ::Foreman::Renderer.get_scope

      result = scope.load_errata_applications
      application = result.first

      assert application.key?(:date)
      assert application.key?(:hostname)
      assert application.key?(:erratum_id)
      assert application.key?(:erratum_type)
      assert application.key?(:issued)
      assert application.key?(:status)
      assert application.key?(:still_applicable)
    end

    def test_load_errata_applications_expands_multiple_errata
      create_errata_application(@host, [@errata, @bugfix])
      scope = ::Foreman::Renderer.get_scope

      result = scope.load_errata_applications

      assert_equal 2, result.count
      erratum_ids = result.map { |r| r[:erratum_id] }
      assert_includes erratum_ids, @errata.errata_id
      assert_includes erratum_ids, @bugfix.errata_id
    end

    def test_load_errata_applications_filter_by_status
      create_errata_application(@host, [@errata], status: 'success')
      create_errata_application(@host, [@bugfix], status: 'error')
      scope = ::Foreman::Renderer.get_scope

      result = scope.load_errata_applications(status: 'success')

      assert_equal 1, result.count
      assert_equal 'success', result.first[:status]
    end

    def test_load_errata_applications_filter_by_errata_type
      create_errata_application(@host, [@errata, @bugfix])
      scope = ::Foreman::Renderer.get_scope

      result = scope.load_errata_applications(filter_errata_type: 'security')

      assert_equal 1, result.count
      assert(result.all? { |app| app[:erratum_type] == 'security' })
    end

    def test_load_errata_applications_filter_by_date_range
      create_errata_application(@host, [@errata], applied_at: 3.days.ago)
      create_errata_application(@host, [@bugfix], applied_at: Time.zone.now)
      scope = ::Foreman::Renderer.get_scope

      since = 2.days.ago.iso8601
      result = scope.load_errata_applications(since: since)

      erratum_ids = result.map { |r| r[:erratum_id] }
      assert_includes erratum_ids, @bugfix.errata_id
      refute_includes erratum_ids, @errata.errata_id
    end

    def test_load_errata_applications_include_last_reboot_yes
      create_errata_application(@host, [@errata])
      scope = ::Foreman::Renderer.get_scope

      result = scope.load_errata_applications(include_last_reboot: 'yes')

      assert result.first.key?(:last_reboot_time)
    end

    def test_load_errata_applications_include_last_reboot_no
      create_errata_application(@host, [@errata])
      scope = ::Foreman::Renderer.get_scope

      result = scope.load_errata_applications(include_last_reboot: 'no')

      refute result.first.key?(:last_reboot_time)
    end

    def test_load_errata_applications_fallback_to_legacy
      Katello::ErrataApplication.stubs(:table_exists?).returns(false)
      scope = ::Foreman::Renderer.get_scope
      scope.expects(:load_errata_applications_legacy).with(
        filter_errata_type: nil,
        include_last_reboot: 'yes',
        since: nil,
        up_to: nil,
        status: nil,
        host_filter: nil
      ).returns([])

      result = scope.load_errata_applications

      assert_empty result
    end

    private

    def create_errata_application(host, errata_list, status: 'success', applied_at: Time.zone.now)
      Katello::ErrataApplication.create!(
        host: host,
        errata_ids: errata_list.map(&:id),
        applied_at: applied_at,
        status: status,
        user: @user
      )
    end
  end
end
