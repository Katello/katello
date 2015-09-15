# encoding: utf-8

require 'katello_test_helper'

module Katello
  class OperatingsystemExtensionsTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin))
      @my_distro = OpenStruct.new(:name => 'RedHat', :family => 'Red Hat Enterprise Linux', :version => '9.0')
    end

    def test_assign_template
      template = templates(:mystring2)
      ptable = FactoryGirl.create(:ptable)

      Setting.create(:name => 'katello_default_provision', :description => 'default template',
                     :category => 'Setting::Katello', :settings_type => 'string',
                     :default => template.name)

      Setting.create(:name => 'katello_default_ptable', :description => 'default template',
                     :category => 'Setting::Katello', :settings_type => 'string',
                     :default => ptable.name)

      os = ::Redhat.create_operating_system(@my_distro.name, '9', '0')
      assert ::OsDefaultTemplate.where(:template_kind_id    => ::TemplateKind.find_by_name('provision').id,
                                       :provisioning_template_id  => template.id,
                                       :operatingsystem_id  => os.id).any?

      assert os.ptables.include? ptable
    end
  end
end
