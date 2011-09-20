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
require 'util/package_util'

describe Katello::PackageUtils do

  let(:nvrea1) { "1:name-ver.si.on-relea.se.arch.rpm" }
  let(:nvrea1_hash) {
    { :epoch => "1",
      :name  => "name",
      :version => "ver.si.on",
      :release => "relea.se",
      :arch => "arch",
      :suffix => "rpm"
    }
  }

  let(:nvrea2) { "1:name-ver.si.on-relea.se.arch" }
  let(:nvrea2_hash) {
    { :epoch => "1",
      :name  => "name",
      :version => "ver.si.on",
      :release => "relea.se",
      :arch => "arch",
    }
  }

  let(:nvrea3) { "name-ver.si.on-relea.se.arch.rpm" }
  let(:nvrea3_hash) {
    { :name  => "name",
      :version => "ver.si.on",
      :release => "relea.se",
      :arch => "arch",
      :suffix => "rpm"
    }
  }

  let(:nvrea4) { "name-ver.si.on-relea.se.arch" }
  let(:nvrea4_hash) {
    { :name  => "name",
      :version => "ver.si.on",
      :release => "relea.se",
      :arch => "arch"
    }
  }

  let(:nvre1) { "1:name-ver.si.on-relea.se" }
  let(:nvre1_hash) {
    { :epoch => "1",
      :name  => "name",
      :version => "ver.si.on",
      :release => "relea.se"
    }
  }

  let(:nvre2) { "name-ver.si.on-relea.se" }
  let(:nvre2_hash) {
    { :name  => "name",
      :version => "ver.si.on",
      :release => "relea.se"
    }
  }


  it "should parse nvre" do
    Katello::PackageUtils.parse_nvre(nvre1).should == nvre1_hash
    Katello::PackageUtils.parse_nvre(nvre2).should == nvre2_hash
  end

  it "should parse nvrea" do
    Katello::PackageUtils.parse_nvrea(nvrea1).should == nvrea1_hash
    Katello::PackageUtils.parse_nvrea(nvrea2).should == nvrea2_hash
    Katello::PackageUtils.parse_nvrea(nvrea3).should == nvrea3_hash
    Katello::PackageUtils.parse_nvrea(nvrea4).should == nvrea4_hash
  end

  it "should build nvre" do
    Katello::PackageUtils.build_nvrea(nvre1_hash).should == nvre1
    Katello::PackageUtils.build_nvrea(nvre2_hash).should == nvre2
  end

end
