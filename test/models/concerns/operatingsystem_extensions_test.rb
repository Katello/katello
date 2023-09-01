# encoding: utf-8

require 'katello_test_helper'

module Katello
  class OperatingsystemExtensionsTest < ActiveSupport::TestCase
    let(:template) { templates(:mystring2) }
    let(:ptable) { FactoryBot.create(:ptable) }

    def setup
      User.current = User.find(users(:admin).id)
      @my_distro = OpenStruct.new(:name => 'RedHat', :family => 'Red Hat Enterprise Linux', :version => '9.0')
      Setting['katello_default_ptable'] = ptable.name
    end

    def test_assign_template
      Setting['katello_default_provision'] = template.name
      os = ::Redhat.create_operating_system(@my_distro.name, '9', '0')
      assert ::OsDefaultTemplate.where(:template_kind_id => ::TemplateKind.find_by_name('provision').id,
                                       :provisioning_template_id => template.id,
                                       :operatingsystem_id => os.id).any?

      assert_includes os.ptables, ptable
    end

    def test_assign_template_for_atomic
      Setting['katello_default_atomic_provision'] = template.name
      os_attributes = {:major => "7", :minor => "3", :name => ::Operatingsystem::REDHAT_ATOMIC_HOST_OS}
      os = Operatingsystem.create!(os_attributes)

      assert ::OsDefaultTemplate.where(:template_kind_id => ::TemplateKind.find_by_name('provision').id,
                                       :provisioning_template_id => template.id,
                                       :operatingsystem_id => os.id).any?

      assert_includes os.ptables, ptable
      assert_equal "Redhat", os.family
      assert_equal "x86_64", os.architectures.first.name
      assert_equal "#{::Operatingsystem::REDHAT_ATOMIC_HOST_DISTRO_NAME} 7.3", os.description
    end

    def test_rhel_eos_schedule_index
      os = Operatingsystem.create!(:name => "RedHat", :major => "7", :minor => "3")
      assert_equal "RHEL7", os.rhel_eos_schedule_index
      assert_equal "RHEL7 (POWER9)", os.rhel_eos_schedule_index(arch_name: "ppc64le")
      assert_equal "RHEL7 (ARM)", os.rhel_eos_schedule_index(arch_name: "aarch64")
      assert_equal "RHEL7 (System z (Structure A))", os.rhel_eos_schedule_index(arch_name: "s390x")

      os = Operatingsystem.create!(:name => "RedHat", :major => "6", :minor => "3")
      assert_equal "RHEL6", os.rhel_eos_schedule_index
    end

    def test_rhel_eos_schedule_index_non_rhel
      os = Operatingsystem.create!(:name => "CentOS_Stream", :major => "8", :minor => "3")
      assert_nil os.rhel_eos_schedule_index
    end
  end
end
