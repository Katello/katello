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

shared_examples_for "protected action" do
  before(:each) do
    # it takes action from describe method
  end
  context "I have sufficient rights" do
    it "should let me to it" do
      unless defined? on_success
        @controller.stub(action) 
        @controller.stub(:render)
      end
      login_user(:user =>  authorized_user, :mock => false, :superuser => false)  if defined?  authorized_user 
      before_success if defined?(before_success)
      @controller.should_not_receive(:render_403)
      req
      on_success if defined?(on_success)
    end
  end
  context "I have not sufficient rights" do
    it "should not let me to it" do
      unless defined? on_failure
        @controller.stub(action)
        @controller.stub(:render)
      end
      login_user(:user =>  unauthorized_user, :mock => false, :superuser => false) if defined?  unauthorized_user 
      before_failure if defined?(before_failure)      
      @controller.should_receive(:render_403)
      req
      on_failure if defined?(on_failure)      
    end
  end
end


