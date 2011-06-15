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

require 'util/url_matcher'

describe UrlMatcher do

  it "should accept empty string and array" do
    m = UrlMatcher.match('', [])
    m[0].should be_nil
    m.size.should equal(1)
  end

  it "should not match different paths" do
    m = UrlMatcher.match('/asdf', ['/abcd'])
    m[0].should be_nil
    m.size.should equal(1)
  end

  it "should accept /" do
    m = UrlMatcher.match('/', ['/'])
    m[0].should match('/')
    m.size.should equal(1)
  end

  it "should accept /x/y/z" do
    m = UrlMatcher.match('/80/01/15', ['/:year/:month/:day'])
    m[0].should match('/:year/:month/:day')
    m[1].should match('80')
    m[2].should match('01')
    m[3].should match('15')
  end

  it "should match fist always" do
    m = UrlMatcher.match('/80/01/15', ['/:a/:b/:c', '/:year/:month/:day'])
    m[0].should match('/:a/:b/:c')
    m[1].should match('80')
    m[2].should match('01')
    m[3].should match('15')
  end

end
