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

  it "should not work when different strings are there" do
    db = Password.update('abc')
    Password.check('cba', db).should be_false
  end

  it "should encrypt and decrypt empty string" do
    # writes some messages to STDERR but works as expected
    encrypted = Password.encrypt('')
    Password.decrypt(encrypted).should == ''
  end

  it "should encrypt and decrypt 'a' string" do
    encrypted = Password.encrypt('a', 'test')
    Password.decrypt(encrypted, 'test').should == 'a'
  end

  it "should encrypt and decrypt very long string" do
    encrypted = Password.encrypt('a' * 999, 'test')
    Password.decrypt(encrypted, 'test').should == 'a' * 999
  end
end
