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

  describe "nvrea" do

    shared_examples_for "nvrea parsable string" do
      it "can be parsed" do
        Katello::PackageUtils.parse_nvrea(subject).should == expected
      end
    end

    context "full nvrea with rpm" do
      subject { "1:name-ver.si.on-relea.se.arch.rpm" }
      let(:expected) do
        { :epoch => "1",
          :name  => "name",
          :version => "ver.si.on",
          :release => "relea.se",
          :arch => "arch",
          :suffix => "rpm" }
      end

      it_should_behave_like "nvrea parsable string"
    end

    context "full nvrea without rpm" do
      subject { "1:name-ver.si.on-relea.se.arch" }
      let(:expected) do
        { :epoch => "1",
          :name  => "name",
          :version => "ver.si.on",
          :release => "relea.se",
          :arch => "arch", }
      end

      it_should_behave_like "nvrea parsable string"
    end

    context "nvrea with rpm without epoch" do
      subject { "name-ver.si.on-relea.se.arch.rpm" }
      let(:expected) do
        { :name  => "name",
          :version => "ver.si.on",
          :release => "relea.se",
          :arch => "arch",
          :suffix => "rpm" }
      end

      it_should_behave_like "nvrea parsable string"
    end

    context "nvrea without rpm and epoch" do
      subject { "name-ver.si.on-relea.se.arch" }
      let(:expected) do
        { :name  => "name",
          :version => "ver.si.on",
          :release => "relea.se",
          :arch => "arch" }
      end

      it_should_behave_like "nvrea parsable string"
    end
  end

  describe "nvre" do

    shared_examples_for "nvre parsable string" do
      it "can be parsed" do
        Katello::PackageUtils.parse_nvre(subject).should == expected
      end

      it "can be build" do
        Katello::PackageUtils.build_nvrea(expected).should == subject
      end
    end

    context "full nvre" do
      subject { "1:name-ver.si.on-relea.se" }
      let(:expected) do
        { :epoch => "1",
          :name  => "name",
          :version => "ver.si.on",
          :release => "relea.se" }
      end

      it_should_behave_like "nvre parsable string"
    end

    context "nvre without epoch" do
      subject { "name-ver.si.on-relea.se" }
      let(:expected) do
        { :name  => "name",
          :version => "ver.si.on",
          :release => "relea.se"
        }
      end

      it_should_behave_like "nvre parsable string"
    end
  end
end
