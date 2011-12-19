
## Copyright 2011 Red Hat, Inc.
##
## This software is licensed to you under the GNU General Public
## License as published by the Free Software Foundation; either version
## 2 of the License (GPLv2) or (at your option) any later version.
## There is NO WARRANTY for this software, express or implied,
## including the implied warranties of MERCHANTABILITY,
## NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
## have received a copy of GPLv2 along with this software; if not, see
## http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'spec_helper'

describe Api::GpgKeysController do

  before(:each) do
    @gpg_key = GpgKey.create!( :name => "Another Test Key", :content => "This is the key data string", :organization => new_test_org )
  end

  describe "GET content" do
    describe "with valid GPG Key id" do

      it "should be successful" do
        get :content, :id => @gpg_key.id
        response.body.should == @gpg_key.content
      end
    end

    describe "with invalid GPG Key id" do
      it "should be unsuccessful" do
        get :content, :id => 9999
        response.response_code.should == 404
      end
    end
  end

end

