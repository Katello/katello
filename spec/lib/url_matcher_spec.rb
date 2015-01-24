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
