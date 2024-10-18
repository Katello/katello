# encoding: utf-8

require 'katello_test_helper'

module Katello
  class HostgroupKickstartRepositoryValidatorTest < ActiveSupport::TestCase
    def setup
      @validator = Validators::HostgroupKickstartRepositoryValidator.new({})
      @os = ::Redhat.create_operating_system('RedHat', '9', '0')
      content_source = FactoryBot.create(:smart_proxy)
      library_environment = katello_environments(:library)
      content_view = katello_content_views(:library_view)
      content_source.lifecycle_environments = [library_environment]

      @repos = [{:name => "foo", :id => 4}]
      @error_messages = {
        :missing_os => 'Please select an operating system before assigning a kickstart repository',
        :missing_arch => 'Please select an architecture before assigning a kickstart repository',
        :invalid_os => 'Kickstart repositories can only be assigned to hosts in the Red Hat family',
        :missing_content_source => 'Please select a content source before assigning a kickstart repository',
        :missing_content_view => 'The selected/Inherited Content View is not available for this Lifecycle Environment',
        :mismatched_ks_repo => 'The selected kickstart repository is not part of the assigned content view, lifecycle environment, ' \
                               'content source, operating system, and architecture'
      }
      @content_facet = Katello::Hostgroup::ContentFacet.new(
        :kickstart_repository_id => 4,
        :lifecycle_environment_id => library_environment.id,
        :content_view_id => content_view.id,
        :content_source_id => content_source.id)
      @hostgroup = ::Hostgroup.new(
        :operatingsystem => @os,
        :architecture => ::Architecture.new,
        :content_facet => @content_facet)
    end

    test 'it validates a hostgroup' do
      @os.expects(:kickstart_repos).returns(@repos)

      @validator.validate(@content_facet)

      assert_empty @content_facet.hostgroup.errors[:kickstart_repository]
    end

    test 'it invalidates on missing OS' do
      @hostgroup.operatingsystem = nil

      @validator.validate(@content_facet)

      assert_equal @error_messages[:missing_os], @content_facet.hostgroup.errors[:base].first
    end

    test 'it invalidates on missing arch' do
      @hostgroup.architecture = nil

      @validator.validate(@content_facet)

      assert_equal @error_messages[:missing_arch], @content_facet.hostgroup.errors[:base].first
    end

    test 'it short-circuits on nil kickstart repo id' do
      @content_facet.kickstart_repository_id = nil
      @hostgroup.expects(:operatingsystem).never

      @validator.validate(@content_facet)

      assert_empty @content_facet.errors.map { |error| error.message }
    end

    test 'it invalidates missing content source on a hostgroup' do
      @content_facet.content_source_id = nil

      @validator.validate(@content_facet)

      assert_equal @error_messages[:missing_content_source], @content_facet.hostgroup.errors[:content_source].first
    end

    test 'it invalidates non-RedHat OS on a hostgroup' do
      @hostgroup.operatingsystem = ::Operatingsystem.new

      @validator.validate(@content_facet)

      assert_equal @error_messages[:invalid_os], @content_facet.hostgroup.errors[:base].first
    end

    test 'it invalidates if content_view not in environment' do
      @content_facet.lifecycle_environment_id = katello_environments(:candlepin_dev).id
      @validator.validate(@content_facet)
      assert_equal @error_messages[:missing_content_view], @content_facet.hostgroup.errors[:lifecycle_environment].first
    end

    test 'it invalidates mismatched selected ks repo on a hostgroup' do
      @content_facet.kickstart_repository_id = 5
      @os.expects(:kickstart_repos).returns(@repos)

      @validator.validate(@content_facet)

      assert_equal @error_messages[:mismatched_ks_repo], @content_facet.hostgroup.errors[:kickstart_repository].first
    end
  end
end
