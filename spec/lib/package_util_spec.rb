#
# Copyright 2013 Red Hat, Inc.
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

describe Util::Package, :katello => true do

  describe "nvrea" do

    shared_examples_for "nvrea parsable string" do
      it "can be parsed" do
        Util::Package.parse_nvrea(subject).should == expected
      end
    end

    shared_examples_for "nvrea_nvre parsable string" do
      it "can be parsed" do
        Util::Package.parse_nvrea_nvre(subject).should == expected
      end
    end

    context "name not in nvrea format" do
      subject { "this-is-not-nvrea" }

      it "can not be parsed by nvrea" do
        Util::Package.parse_nvrea(subject).should be_nil
      end
    end

    context "full nvrea with rpm" do
      subject { "1:name-ver.si.on-relea.se.x86_64.rpm" }
      let(:expected) do
        { :epoch => "1",
          :name  => "name",
          :version => "ver.si.on",
          :release => "relea.se",
          :arch => "x86_64",
          :suffix => "rpm" }
      end

      it_should_behave_like "nvrea parsable string"
      it_should_behave_like "nvrea_nvre parsable string"
    end

    context "full nvrea without rpm" do
      subject { "1:name-ver.si.on-relea.se.x86_64" }
      let(:expected) do
        { :epoch => "1",
          :name  => "name",
          :version => "ver.si.on",
          :release => "relea.se",
          :arch => "x86_64" }
      end

      it_should_behave_like "nvrea parsable string"
      it_should_behave_like "nvrea_nvre parsable string"
    end

    context "nvrea with dash and dots in name and rpm" do
      subject { "name-with-dashes-and.dots-1.0-1.noarch.rpm" }
      let(:expected) do
        { :name  => "name-with-dashes-and.dots",
          :version => "1.0",
          :release => "1",
          :arch => "noarch",
          :suffix => "rpm" }
      end
      it_should_behave_like "nvrea parsable string"
      it_should_behave_like "nvrea_nvre parsable string"
    end

    context "nvrea with rpm without epoch" do
      subject { "name-ver.si.on-relea.se.x86_64.rpm" }
      let(:expected) do
        { :name  => "name",
          :version => "ver.si.on",
          :release => "relea.se",
          :arch => "x86_64",
          :suffix => "rpm" }
      end

      it_should_behave_like "nvrea parsable string"
      it_should_behave_like "nvrea_nvre parsable string"
    end

    context "nvrea without rpm and epoch" do
      subject { "name-ver.si.on-relea.se.x86_64" }
      let(:expected) do
        { :name  => "name",
          :version => "ver.si.on",
          :release => "relea.se",
          :arch => "x86_64" }
      end

      it_should_behave_like "nvrea parsable string"
      it_should_behave_like "nvrea_nvre parsable string"
    end
  end

  describe "nvre" do

    shared_examples_for "nvre parsable string" do
      it "can be parsed" do
        Util::Package.parse_nvre(subject).should == expected
      end

      it "can be build" do
        Util::Package.build_nvrea(expected).should == subject
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
      it_should_behave_like "nvrea_nvre parsable string"
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
      it_should_behave_like "nvrea_nvre parsable string"
    end

    context "nvre with dash and dots in name and rpm" do
      subject { "name-with-dashes-and.dots-1.0-1" }
      let(:expected) do
        { :name  => "name-with-dashes-and.dots",
          :version => "1.0",
          :release => "1" }
      end
      it_should_behave_like "nvre parsable string"
      it_should_behave_like "nvrea_nvre parsable string"
    end

  end
end
