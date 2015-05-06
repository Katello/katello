require 'katello_test_helper'
require 'katello/util/url_matcher'

module Katello
  describe Util::UrlMatcher do
    it "should accept empty string and array" do
      m = Util::UrlMatcher.match('', [])
      m[0].must_be_nil
      m.size.must_equal(1)
    end

    it "should not match different paths" do
      m = Util::UrlMatcher.match('/asdf', ['/abcd'])
      m[0].must_be_nil
      m.size.must_equal(1)
    end

    it "should accept /" do
      m = Util::UrlMatcher.match('/', ['/'])
      m[0].must_match('/')
      m.size.must_equal(1)
    end

    it "should accept /x/y/z" do
      m = Util::UrlMatcher.match('/80/01/15', ['/:year/:month/:day'])
      m[0].must_match('/:year/:month/:day')
      m[1].must_match('80')
      m[2].must_match('01')
      m[3].must_match('15')
    end

    it "should match first always" do
      m = Util::UrlMatcher.match('/80/01/15', ['/:a/:b/:c', '/:year/:month/:day'])
      m[0].must_match('/:a/:b/:c')
      m[1].must_match('80')
      m[2].must_match('01')
      m[3].must_match('15')
    end
  end
end
