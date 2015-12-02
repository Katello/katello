require 'katello_test_helper'

module Katello
  describe KatelloUrlHelper do
    describe "Valid https? Urls" do
      it "should validate clean http urls" do
        kurl_valid?('http://www.hugheshoney.com').must_equal(true)
        kurl_valid?('HTtp://www.hugheshoney.com').must_equal(true)
        kurl_valid?('http://www.hugheshoney.com:8888').must_equal(true)
        kurl_valid?('http://www.hugheshoney.com:8888/homepage/index.html').must_equal(true)
        kurl_valid?('http://9seng.cz/katello').must_equal(true)
      end
      it "should validate clean https urls" do
        kurl_valid?('https://www.hugheshoney.com').must_equal(true)
        kurl_valid?('https://www.hugheshoney.com:8888').must_equal(true)
        kurl_valid?('https://www.hugheshoney.com:8888/homepage/index.html').must_equal(true)
      end
      it "should validate clean ipv4 urls" do
        kurl_valid?('https://65.190.152.28').must_equal(true)
        kurl_valid?('http://65.190.152.28:88').must_equal(true)
        kurl_valid?('http://65.190.152.28:88/homepage/index.html').must_equal(true)
      end
      it "should validate clean localhost urls" do
        kurl_valid?('http://localhost').must_equal(true)
        kurl_valid?('https://localhost').must_equal(true)
        kurl_valid?('https://127.0.0.1/').must_equal(true)
        kurl_valid?('https://127.0.0.1/index.php').must_equal(true)
        kurl_valid?('https://127.0.0.1:80/index.php').must_equal(true)
      end
      it "should validate clean ftp urls" do
        kurl_valid?('ftp://65.190.152.28').must_equal(true)
        kurl_valid?('Ftp://65.190.152.28').must_equal(true)
        kurl_valid?('ftp://65.190.152.28/fedora/x86_64').must_equal(true)
        kurl_valid?('ftp://ftp.fedorahosted.org/rpms/index.html').must_equal(true)
      end

      it "should validate file urls" do
        file_prefix?('file://opt/repo').must_equal(true)
        file_prefix?('/opt/repo').must_equal(false)
        file_prefix?('file://opt/repo-is-long/').must_equal(true)
        file_prefix?('/opt/repo-for-me').must_equal(false)
      end

      it "should validate file urls with multiple slashes" do
        file_prefix?('file://///opt/repo').must_equal(true)
        file_prefix?('file://///opt/').must_equal(true)
        file_prefix?('File://///opt/').must_equal(true)
        file_prefix?('/////opt/repo').must_equal(false)
        file_prefix?('/////opt/repo').must_equal(false)
      end

      it "should validate not fully qualified domain names" do
        kurl_valid?('http://seng9/katello').must_equal(true)
        kurl_valid?('http://s-eng').must_equal(true)
        kurl_valid?('http://seng').must_equal(true)
      end

      it "should validate urls with usernames and passwords" do
        kurl_valid?('http://admin:admin@foo.com/').must_equal(true)
      end
    end

    describe "Invalid Urls" do
      it "should catch invalid missing protocols" do
        kurl_valid?('123.190.152.28').must_equal(false)
        kurl_valid?('www.hugheshoney.com').must_equal(false)
      end
      it "should catch invalid generic urls" do
        kurl_valid?('www..foo.com').must_equal(false)
        kurl_valid?('www..foo.com').must_equal(false)
        kurl_valid?('htttp://foo.bar.edu').must_equal(false)
      end
      it "should catch domains with invalid dashes" do
        kurl_valid?('-seng9').must_equal(false)
        kurl_valid?('seng9-.com').must_equal(false)
      end
    end
  end
end
