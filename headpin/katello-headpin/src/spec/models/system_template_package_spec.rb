#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'spec_helper'
require 'helpers/repo_test_data'

include OrchestrationHelper

describe SystemTemplate do

  before :each do
    disable_org_orchestration

    @organization = Organization.create!(:name => 'test_organization', :cp_key => 'test_organization')
    @tpl = SystemTemplate.create!(:name => "template_1", :environment => @organization.library)
  end

  let(:package_1) {{
    :package_name => 'foo',
    :version => '0.1',
    :release => '4.1',
    :epoch => '1'
  }}

  describe "create template" do

    it "should create a template package with correct attributes" do
      @tpl.environment.stub(:find_packages_by_nvre).and_return([package_1])
      @tpl.environment.stub(:find_packages_by_name).and_return([package_1])

      stp = SystemTemplatePackage.new(package_1.slice(:package_name))
      stp.system_template = @tpl
      lambda {stp.save!}.should_not raise_error
    end

    it "should fail when creating a package without a name" do
      @tpl.environment.stub(:find_packages_by_nvre).and_return([package_1])
      @tpl.environment.stub(:find_packages_by_name).and_return([package_1])

      stp = SystemTemplatePackage.new(package_1.except(:package_name))
      stp.system_template = @tpl
      lambda {stp.save!}.should raise_error
    end

    it "should fail when creating a package with duplicate name" do
      @tpl.environment.stub(:find_packages_by_nvre).and_return([package_1])
      @tpl.environment.stub(:find_packages_by_name).and_return([package_1])

      stp1 = SystemTemplatePackage.new(package_1.slice(:package_name))
      stp1.system_template = @tpl
      stp1.save!

      stp2 = SystemTemplatePackage.new(package_1.slice(:package_name))
      stp2.system_template = @tpl
      lambda {stp2.save!}.should raise_error
    end

    it "should fail when creating a package with duplicate nvre" do
      @tpl.environment.stub(:find_packages_by_nvre).and_return([package_1])
      @tpl.environment.stub(:find_packages_by_name).and_return([package_1])

      stp1 = SystemTemplatePackage.new(package_1)
      stp1.system_template = @tpl
      stp1.save!

      stp2 = SystemTemplatePackage.new(package_1)
      stp2.system_template = @tpl
      lambda {stp2.save!}.should raise_error
    end

    it "should fail when creating a package by nvre that is not in the template's environment" do
      @tpl.environment.stub(:find_packages_by_nvre).with(package_1[:package_name], package_1[:version], package_1[:release], package_1[:epoch]).and_return([])

      stp = SystemTemplatePackage.new(package_1)
      stp.system_template = @tpl

      lambda {stp.save!}.should raise_error
    end

    it "should fail when creating a package by name that is not in the template's environment" do
      @tpl.environment.stub(:find_packages_by_name).with(package_1[:package_name]).and_return([])

      stp = SystemTemplatePackage.new(package_1)
      stp.system_template = @tpl

      lambda {stp.save!}.should raise_error
    end
  end

end
