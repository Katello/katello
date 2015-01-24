#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'

module Katello
  describe Resources::CDN::CdnResource do
    let(:provider_url) { "https://cdn.redhat.com" }
    let(:path_with_variables) { "/content/dist/rhel/server/5/$releasever/$basearch/os" }
    let(:another_path_with_variables) { "/content/dist/rhel/server/6/$releasever/$basearch/os" }
    let(:connect_options) do
      {:ssl_client_cert => "456", :ssl_ca_file => "fake-ca.pem", :ssl_client_key => "123",
       :product => OpenStruct.new}
    end

    before do
      Net::HTTP.stubs("Proxy").returns(Net::HTTP)
    end

    subject do
      Resources::CDN::CdnResource.new(provider_url, connect_options).substitutor
    end

    it "should substitute all variables with values in listings 6/i386" do
      Net::HTTP.any_instance.stubs(:start).returns("6\ni386")
      substitutions_with_urls = subject.substitute_vars(path_with_variables)
      substitutions_with_urls[{"releasever" => "6", "basearch" => "i386"}].must_equal "/content/dist/rhel/server/5/6/i386/os"
    end

    it "should substitute all variables with values in listings 61/i386" do
      Net::HTTP.any_instance.stubs(:start).returns("61\ni386")
      substitutions_with_urls = subject.substitute_vars(path_with_variables)
      substitutions_with_urls[{"releasever" => "61", "basearch" => "i386"}].must_equal "/content/dist/rhel/server/5/61/i386/os"
    end

    it "should substitute all variables with values in listings 6/x86_64" do
      Net::HTTP.any_instance.stubs(:start).returns("6\nx86_64")
      substitutions_with_urls = subject.substitute_vars(path_with_variables)
      substitutions_with_urls[{"releasever" => "6", "basearch" => "x86_64"}].must_equal "/content/dist/rhel/server/5/6/x86_64/os"
    end

    it "should substitute all variables with values in listings 61/x86_64" do
      Net::HTTP.any_instance.stubs(:start).returns("61\nx86_64")
      substitutions_with_urls = subject.substitute_vars(path_with_variables)
      substitutions_with_urls[{"releasever" => "61", "basearch" => "x86_64"}].must_equal "/content/dist/rhel/server/5/61/x86_64/os"
    end

    describe "batch substitutions calculation" do
      it "should calculate all substitutions at once" do
        Net::HTTP.any_instance.stubs(:start).returns("")
        subject.expects(:substitute_vars).with(path_with_variables).returns([])
        subject.expects(:substitute_vars).with(another_path_with_variables).returns([])
        subject.precalculate([path_with_variables, another_path_with_variables])
      end

      it "should use the precalculated results for substitutions" do
        Net::HTTP.any_instance.stubs(:start).returns("")
        subject.precalculate([path_with_variables])
        subject.expects(:for_each_substitute_of_next_var).never # doesn't calculate results
        subject.substitute_vars(path_with_variables)
      end
    end

    it "it should be able to cache the resolved paths" do
      Net::HTTP.any_instance.stubs(:start).returns("6\nx86_64")
      Util::CdnVarSubstitutor.with_cache do
        Resources::CDN::CdnResource.new(provider_url, connect_options).substitutor.substitute_vars(path_with_variables)
        Resources::CDN::CdnResource.new(provider_url, connect_options).substitutor.substitute_vars(path_with_variables)
      end
    end

    it "it should cache the resolved paths only in with_cache block" do
      Net::HTTP.any_instance.stubs(:start).returns("6\nx86_64")
      Util::CdnVarSubstitutor.with_cache do
        Resources::CDN::CdnResource.new(provider_url, connect_options).substitutor.substitute_vars(path_with_variables)
      end
      Resources::CDN::CdnResource.new(provider_url, connect_options).substitutor.substitute_vars(path_with_variables)
    end
  end
end
