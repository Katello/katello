# encoding: utf-8

require 'katello_test_helper'

module Katello
  class KickstartRepositoryValidatorTest < ActiveSupport::TestCase
    def setup
      @validator = Validators::KickstartRepositoryValidator.new({})
      @os = ::Redhat.create_operating_system('RedHat', '9', '0')
      @content_source = FactoryGirl.create(:smart_proxy, :name => "foobar", :url => "http://capsule.com/")
      @repos = [{:name => "foo", :id => 4}]
      @error_messages = {
        :missing_os => 'Please select an operating system before assigning a kickstart repository',
        :missing_arch => 'Please select an architecture before assigning a kickstart repository',
        :invalid_os => 'Kickstart repositories can only be assigned to hosts in the Red Hat family',
        :missing_content_source => 'Please select a content source before assigning a kickstart repository',
        :mismatched_ks_repo => 'The selected kickstart repository is not part of the assigned content view, lifecycle environment,
                  content source, operating system, and architecture'
      }
      @hostgroup = ::Hostgroup.new(:operatingsystem => @os, :kickstart_repository_id => 4,
                                   :architecture => ::Architecture.new, :content_source_id => @content_source.id)
      @host = ::Host.new(:operatingsystem => @os, :architecture => ::Architecture.new,
                        :content_facet_attributes => {
                          :content_source_id => @content_source.id,
                          :kickstart_repository_id => 4
                        })
    end

    test 'it validates a host' do
      @os.expects(:kickstart_repos).returns(@repos)

      @validator.validate(@host)

      assert_empty @host.errors[:base]
    end

    test 'it validates a hostgroup' do
      @os.expects(:kickstart_repos).returns(@repos)

      @validator.validate(@hostgroup)

      assert_empty @hostgroup.errors[:base]
    end

    test 'it invalidates on missing OS' do
      @host.operatingsystem = nil

      @validator.validate(@host)

      assert_equal @error_messages[:missing_os], @host.errors[:base].first
    end

    test 'it invalidates on missing arch' do
      @host.architecture = nil

      @validator.validate(@host)

      assert_equal @error_messages[:missing_arch], @host.errors[:base].first
    end

    test 'it short-circuits on nil kickstart repo id' do
      @host.content_facet.kickstart_repository_id = nil
      @host.expects(:operatingsystem).never

      @validator.validate(@host)

      assert_empty @host.errors.values
    end

    test 'it short-circuits unless ks repo has changed on a host' do
      @host.expects(:operatingsystem).never
      @host.content_facet.expects(:kickstart_repository_id_changed?).returns(false)

      @validator.validate(@host)

      assert_empty @host.errors.values
    end

    test 'it short-circuits unless ks repo has changed on a hostgroup' do
      @hostgroup.expects(:operatingsystem).never
      @hostgroup.expects(:kickstart_repository_id_changed?).returns(false)

      @validator.validate(@hostgroup)

      assert_empty @hostgroup.errors.values
    end

    test 'it invalidates missing content source on a host' do
      @host.content_facet.content_source_id = nil

      @validator.validate(@host)

      assert_equal @error_messages[:missing_content_source], @host.errors[:base].first
    end

    test 'it invalidates missing content source on a hostgroup' do
      @hostgroup.content_source_id = nil
      @validator.validate(@hostgroup)

      assert_equal @error_messages[:missing_content_source], @hostgroup.errors[:base].first
    end

    test 'it invalidates non-RedHat OS on a hostgroup' do
      @hostgroup.operatingsystem = ::Operatingsystem.new

      @validator.validate(@hostgroup)

      assert_equal @error_messages[:invalid_os], @hostgroup.errors[:base].first
    end

    test 'it invalidates non-RedHat OS on a host' do
      @host.operatingsystem = ::Operatingsystem.new

      @validator.validate(@host)

      assert_equal @error_messages[:invalid_os], @host.errors[:base].first
    end

    test 'it invalidates mismatched selected ks repo on a host' do
      @host.content_facet.kickstart_repository_id = 5
      @os.expects(:kickstart_repos).returns(@repos)

      @validator.validate(@host)

      assert_equal @error_messages[:mismatched_ks_repo], @host.errors[:base].first
    end

    test 'it invalidates mismatched selected ks repo on a hostgroup' do
      @hostgroup.kickstart_repository_id = 5
      @os.expects(:kickstart_repos).returns(@repos)

      @validator.validate(@hostgroup)

      assert_equal @error_messages[:mismatched_ks_repo], @hostgroup.errors[:base].first
    end
  end
end
