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

require 'util/model_util'

describe Katello::ModelUtils do

  it "should work with tag" do
    Katello::ModelUtils.table_to_class("tag").class_name.should match("Tag")
  end

  it "should work with system_template" do
    Katello::ModelUtils.table_to_class("system_template").class_name.should match("SystemTemplate")
  end

  it "should work with kt_environment" do
    Katello::ModelUtils.table_to_class("kt_environment").class_name.should match("KTEnvironment")
  end

  it "should return tags for organization" do
    disable_org_orchestration
    @o1 = Organization.create!(:name => 'test_org1', :cp_key => 'test_org1')
    @o2 = Organization.create!(:name => 'test_org2', :cp_key => 'test_org2')
    Organization.stub!(:all).and_return([@o1, @o2])
    Tag.tags_for("organizations", nil).size.should be(2)
  end

end
