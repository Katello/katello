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

    context 'use predefined templates for debian' do
      setup do
        template_name = format(::Operatingsystem::DEBIAN_DEFAULT_PROVISIONING_TEMPLATE, template_kind_name: 'PXELinux')
        @provisioning_template = FactoryBot.create(:provisioning_template, :template_kind => TemplateKind.find_by_name(:PXELinux), :name => template_name)
        @ptable = FactoryBot.create(:ptable, :ubuntu, :name => ::Operatingsystem::DEBIAN_DEFAULT_PTABLE)
      end

      def test_assign_template_from_predefined
        ProvisioningTemplate.stubs(:find_by_name).returns(@provisioning_template)
        Ptable.stubs(:find_by_name).returns(@ptable)

        # if find_related_os returns nil, it should use the default template
        Operatingsystem.any_instance.stubs(:find_related_os).returns(nil)

        os_attributes = {:major => "22.04", :minor => "", :name => 'Ubuntu', :release_name => 'jammy'}
        os = Operatingsystem.create!(os_attributes)

        assert ::OsDefaultTemplate.where(:template_kind_id => ::TemplateKind.find_by_name('PXELinux').id,
                                         :provisioning_template_id => @provisioning_template.id,
                                         :operatingsystem_id => os.id).any?
        assert_includes os.ptables, @ptable
      end
    end

    context 'use find_relates_os templates for sles' do
      setup do
        template_name1 = format(::Operatingsystem::SUSE_DEFAULT_PROVISIONING_TEMPLATE, template_kind_name: 'PXELinux')
        @provisioning_template1 = FactoryBot.create(:provisioning_template, :template_kind => TemplateKind.find_by_name(:PXELinux), :name => template_name1)
        template_name2 = format(::Operatingsystem::SUSE_DEFAULT_PROVISIONING_TEMPLATE, template_kind_name: 'provision')
        @provisioning_template2 = FactoryBot.create(:provisioning_template, :template_kind => TemplateKind.find_by_name(:provision), :name => template_name2)
        template_name3 = format(::Operatingsystem::SUSE_DEFAULT_PROVISIONING_TEMPLATE, template_kind_name: 'host_init_config')
        @provisioning_template3 = FactoryBot.create(:provisioning_template, :template_kind => TemplateKind.find_by_name(:host_init_config), :name => template_name3)
        @ptable = FactoryBot.create(:ptable, :suse, :name => ::Operatingsystem::SUSE_DEFAULT_PTABLE)

        os_attributes1 = {:major => "15", :minor => "1", :name => 'SLES' }
        @os1 = Operatingsystem.create!(os_attributes1)
        @os1.ptables = [@ptable]
        @os1.provisioning_templates = [@provisioning_template1, @provisioning_template2]
        @os1.save!
      end

      def test_assign_template_from_related_first
        os_attributes_new = {:major => "15", :minor => "2", :name => 'SLES' }
        Rails.logger.expects(:info).with("Using operating system #{@os1.name} (major: #{@os1.major}, minor: #{@os1.minor}) " \
                                         "as a template source for the new OS #{os_attributes_new[:name]} " \
                                         "(major: #{os_attributes_new[:major]}, minor: #{os_attributes_new[:minor]}).")
        os_new = Operatingsystem.create!(os_attributes_new)
        assert_equal "2", os_new.minor
        assert_equal "15", os_new.major
        assert ::OsDefaultTemplate.where(:template_kind_id => ::TemplateKind.find_by_name('PXELinux').id,
                                         :provisioning_template_id => @provisioning_template1.id,
                                         :operatingsystem_id => os_new.id).any?
        assert ::OsDefaultTemplate.where(:template_kind_id => ::TemplateKind.find_by_name('provision').id,
                                         :provisioning_template_id => @provisioning_template2.id,
                                         :operatingsystem_id => os_new.id).any?
        assert_includes os_new.ptables, @ptable
      end

      def test_assign_template_from_related_second
        # This is the latest OS with higher minor version but no ptables is assigned -> it need to use @os1 as a template
        os_attributes2 = {:major => "15", :minor => "2", :name => 'SLES' }
        os2 = Operatingsystem.create!(os_attributes2)
        os2.ptables = []
        os2.provisioning_templates = [@provisioning_template1, @provisioning_template2]
        os2.save!

        os_attributes_new = {:major => "15", :minor => "3", :name => 'SLES' }
        Rails.logger.expects(:info).with("Using operating system #{@os1.name} (major: #{@os1.major}, minor: #{@os1.minor}) " \
                                         "as a template source for the new OS #{os_attributes_new[:name]} " \
                                         "(major: #{os_attributes_new[:major]}, minor: #{os_attributes_new[:minor]}).")
        os_new = Operatingsystem.create!(os_attributes_new)
        assert_equal "3", os_new.minor
        assert_equal "15", os_new.major
        assert ::OsDefaultTemplate.where(:template_kind_id => ::TemplateKind.find_by_name('PXELinux').id,
                                         :provisioning_template_id => @provisioning_template1.id,
                                         :operatingsystem_id => os_new.id).any?
        assert ::OsDefaultTemplate.where(:template_kind_id => ::TemplateKind.find_by_name('provision').id,
                                         :provisioning_template_id => @provisioning_template2.id,
                                         :operatingsystem_id => os_new.id).any?
        assert_includes os_new.ptables, @ptable
      end

      def test_assign_template_from_related_third
        # This is the latest OS with higher minor version but specific templates are not assigned -> it need to use @os1 as a template
        os_attributes2 = {:major => "15", :minor => "2", :name => 'SLES' }
        os2 = Operatingsystem.create!(os_attributes2)
        os2.ptables = [@ptable]
        os2.provisioning_templates = [@provisioning_template3]
        os2.save!

        os_attributes_new = {:major => "15", :minor => "3", :name => 'SLES' }
        Rails.logger.expects(:info).with("Using operating system #{@os1.name} (major: #{@os1.major}, minor: #{@os1.minor}) " \
                                         "as a template source for the new OS #{os_attributes_new[:name]} " \
                                         "(major: #{os_attributes_new[:major]}, minor: #{os_attributes_new[:minor]}).")
        os_new = Operatingsystem.create!(os_attributes_new)
        assert_equal "3", os_new.minor
        assert_equal "15", os_new.major
        assert ::OsDefaultTemplate.where(:template_kind_id => ::TemplateKind.find_by_name('PXELinux').id,
                                         :provisioning_template_id => @provisioning_template1.id,
                                         :operatingsystem_id => os_new.id).any?
        assert ::OsDefaultTemplate.where(:template_kind_id => ::TemplateKind.find_by_name('provision').id,
                                         :provisioning_template_id => @provisioning_template2.id,
                                         :operatingsystem_id => os_new.id).any?
        assert @os1.ptables.pluck(:name).all? { |t| os_new.ptables.pluck(:name).include?(t) }
        assert_includes os_new.ptables, @ptable
      end
    end
  end
end
