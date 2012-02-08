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

require 'util/password'

describe Password do

  it "should generate hash of length 192" do
    Password.update('a').length.should equal(192)
  end

  it "should work with empty string" do
    db = Password.update('a')
    Password.check('a', db).should be_true
  end

  it "should work with 'a' string" do
    db = Password.update('a')
    Password.check('a', db).should be_true
  end

  it "should work with 'admin' string" do
    db = Password.update('admin')
    Password.check('admin', db).should be_true
  end

  it "should not work with 'abc' vs 'cba'" do
    db = Password.update('abc')
    Password.check('cba', db).should be_false
  end

  it "should work with 'tclmeSRS' string with given salt" do
    db = 'b05bae176fb8b255c56d0b94389bb146a87cf25b43cab7b5b3bd31078c0db81149d81aaf1574da8b5adeedfd06' +
      '23eeddff6f283ea440964dd1f6b18d921541c5SB2HjUEy0mUEKo858uo8D6GLw5a6gui99PcrNOUI72pe0d3hSbKk08nx9wWBaLit'
    Password.check('tclmeSRS', db).should be_true
  end

  it "should not work when different strings are there" do
    db = Password.update('abc')
    Password.check('cba', db).should be_false
  end

end
