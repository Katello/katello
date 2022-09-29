require 'katello_test_helper'

module Katello
  describe KatelloUrlHelper do
    describe "Valid https? Urls" do
      it "should validate clean http urls" do
        assert kurl_valid?('http://www.hugheshoney.com')
        assert kurl_valid?('HTtp://www.hugheshoney.com')
        assert kurl_valid?('http://www.hugheshoney.com:8888')
        assert kurl_valid?('http://www.hugheshoney.com:8888/homepage/index.html')
        assert kurl_valid?('http://9seng.cz/katello')
      end
      it "should validate clean https urls" do
        assert kurl_valid?('https://www.hugheshoney.com')
        assert kurl_valid?('https://www.hugheshoney.com:8888')
        assert kurl_valid?('https://www.hugheshoney.com:8888/homepage/index.html')
      end
      it "should validate clean ipv4 urls" do
        assert kurl_valid?('https://65.190.152.28')
        assert kurl_valid?('http://65.190.152.28:88')
        assert kurl_valid?('http://65.190.152.28:88/homepage/index.html')
      end
      it "should validate clean localhost urls" do
        assert kurl_valid?('http://localhost')
        assert kurl_valid?('https://localhost')
        assert kurl_valid?('https://127.0.0.1/')
        assert kurl_valid?('https://127.0.0.1/index.php')
        assert kurl_valid?('https://127.0.0.1:80/index.php')
      end
      it "should validate clean ftp urls" do
        assert kurl_valid?('ftp://65.190.152.28')
        assert kurl_valid?('Ftp://65.190.152.28')
        assert kurl_valid?('ftp://65.190.152.28/fedora/x86_64')
        assert kurl_valid?('ftp://ftp.fedorahosted.org/rpms/index.html')
      end

      it "should validate file urls" do
        assert kurl_valid?('file://opt/repo')
        refute kurl_valid?('/opt/repo')
        assert kurl_valid?('file://opt/repo-is-long/')
        refute kurl_valid?('/opt/repo-for-me')
      end

      it "should validate file urls with multiple slashes" do
        assert kurl_valid?('file://///opt/repo')
        assert kurl_valid?('file://///opt/')
        assert kurl_valid?('File://///opt/')
        refute kurl_valid?('/////opt/repo')
        refute kurl_valid?('/////opt/repo')
      end

      it "should validate not fully qualified domain names" do
        assert kurl_valid?('http://seng9/katello')
        assert kurl_valid?('http://s-eng')
        assert kurl_valid?('http://seng')
      end

      it "should validate urls with usernames and passwords" do
        assert kurl_valid?('http://admin:admin@foo.com/')
      end
    end

    describe "Invalid Urls" do
      it "should catch invalid missing protocols" do
        refute kurl_valid?('123.190.152.28')
        refute kurl_valid?('www.hugheshoney.com')
      end
      it "should catch invalid generic urls" do
        refute kurl_valid?('www..foo.com')
        refute kurl_valid?('www..foo.com')
        refute kurl_valid?('htttp://foo.bar.edu')
      end
      it "should catch domains with invalid dashes" do
        refute kurl_valid?('-seng9')
        refute kurl_valid?('seng9-.com')
      end
    end
  end
end
