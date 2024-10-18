require 'katello_test_helper'

module Katello
  describe Util::URLMatcher do
    it "should accept empty string and array" do
      m = Util::URLMatcher.match('', [])
      value(m[0]).must_be_nil
      value(m.size).must_equal(1)
    end

    it "should not match different paths" do
      m = Util::URLMatcher.match('/asdf', ['/abcd'])
      value(m[0]).must_be_nil
      value(m.size).must_equal(1)
    end

    it "should accept /" do
      m = Util::URLMatcher.match('/', ['/'])
      value(m[0]).must_match('/')
      value(m.size).must_equal(1)
    end

    it "should accept /x/y/z" do
      m = Util::URLMatcher.match('/80/01/15', ['/:year/:month/:day'])
      value(m[0]).must_match('/:year/:month/:day')
      value(m[1]).must_match('80')
      value(m[2]).must_match('01')
      value(m[3]).must_match('15')
    end

    it "should match first always" do
      m = Util::URLMatcher.match('/80/01/15', ['/:a/:b/:c', '/:year/:month/:day'])
      value(m[0]).must_match('/:a/:b/:c')
      value(m[1]).must_match('80')
      value(m[2]).must_match('01')
      value(m[3]).must_match('15')
    end
  end
end
