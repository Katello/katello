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
require 'katello_url_helper'

describe KatelloUrlHelper do
    describe "Valid https? Urls" do
      it "should validate clean http urls" do
        kurl_valid?('http://www.hugheshoney.com').should be_true
        kurl_valid?('http://www.hugheshoney.com:8888').should be_true
        kurl_valid?('http://www.hugheshoney.com:8888/homepage/index.html').should be_true
      end
      it "should validate clean https urls" do
        kurl_valid?('https://www.hugheshoney.com').should be_true
        kurl_valid?('https://www.hugheshoney.com:8888').should be_true
        kurl_valid?('https://www.hugheshoney.com:8888/homepage/index.html').should be_true
      end
      it "should validate clean ipv4 urls" do
        kurl_valid?('https://65.190.152.28').should be_true
        kurl_valid?('http://65.190.152.28:88').should be_true
        kurl_valid?('http://65.190.152.28:88/homepage/index.html').should be_true
      end
      it "should validate clean localhost urls" do
        kurl_valid?('http://localhost').should be_true
        kurl_valid?('https://localhost').should be_true
        kurl_valid?('https://127.0.0.1/').should be_true
        kurl_valid?('https://127.0.0.1/index.php').should be_true
        kurl_valid?('https://127.0.0.1:80/index.php').should be_true
      end
      it "should validate clean ftp urls" do
        kurl_valid?('ftp://65.190.152.28').should be_true
        kurl_valid?('ftp://65.190.152.28/fedora/x86_64').should be_true
        kurl_valid?('ftp://ftp.fedorahosted.org/rpms/index.html').should be_true
      end
    end
    describe "Invalid Urls" do
      it "should catch invalid ipv4 urls" do
        kurl_valid?('https://365.190.152.28').should_not be_true
        kurl_valid?('http://65.190.152.28:888888').should_not be_true
        kurl_valid?('http://65.190.1521.28:88/homepage/index.html').should_not be_true
      end
      it "should catch invalid missing protocols" do
        kurl_valid?('123.190.152.28').should_not be_true
        kurl_valid?('www.hugheshoney.com').should_not be_true
      end
      it "should catch invalid generic urls" do
        kurl_valid?('www..foo.com').should_not be_true
        kurl_valid?('www..foo.com').should_not be_true
        kurl_valid?('htttp://foo.bar.edu').should_not be_true
      end
    end
    describe "Invalid Urls" do
      it "should catch missing protocols" do
        kprotocol?('www.hugheshoney.com').should_not be_true
        kprotocol?('http://www.hugheshoney.com').should be_true
        kprotocol?('https://www.hugheshoney.com').should be_true
        kprotocol?('ftp://www.hugheshoney.com').should be_true
      end
    end
end

