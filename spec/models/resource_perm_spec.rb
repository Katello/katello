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

describe ResourcePermissions do

  let(:to_response) do
    '{"key":"test",
     "id":"8aa2a2382f24d980012f24ee51f1000e",
     "displayName":"test",
     "parentOwner":null,
     "href":"/owners/test",
     "upstreamUuid":null,
     "contentPrefix":null,
     "updated":"2011-04-05T09:11:29.009+0000",
     "created":"2011-04-05T09:11:29.009+0000"}'
  end

  before(:each) do
    User.current = User.find_or_create_by_username(:username => 'admin', :password => 'admin12345')
  end

  describe "ResourcePermissions for Candlepin should" do

    it "create set of permissions for new owner and delete after destroy" do
      Candlepin::CandlepinResourcePermissions::after_post_callback('/candlepin/owners/', nil, nil, to_response)
      User.current.allowed_to?('destroy', 'owner', 'owner_test').should be_true
      User.allowed_to?('destroy', 'owner', 'owner_test').should be_true

      # print all permissions to console
      Permission.all.each { |p| Rails.logger.debug p.to_text }

      # delete possible - permissions are there
      lambda { Candlepin::CandlepinResourcePermissions::before_delete_callback('/candlepin/owners/test', nil) }.should_not raise_exception

      # delete owner
      Candlepin::CandlepinResourcePermissions::after_delete_callback('/candlepin/owners/test', nil, nil)

      # permissions should be gone
      User.current.allowed_to?('view', 'owner', 'owner_test').should be_false
      User.current.allowed_to?('edit', 'owner', 'owner_test').should be_false
      User.current.allowed_to?('destroy', 'owner', 'owner_test').should be_false
      User.allowed_to?('view', 'owner', 'owner_test').should be_false
      User.allowed_to?('edit', 'owner', 'owner_test').should be_false
      User.allowed_to?('destroy', 'owner', 'owner_test').should be_false
      lambda { User.allowed_to_or_error?(['view','edit','destroy'], 'owner', 'owner_test') }.should raise_exception
    end

  end

end
