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
    @controller.stub(stub_action) if defined?(stub_action) && !stub_action.nil?
    @controller.stub(:render) if defined?(stub_action) && !stub_action.nil?
    before_action if defined?(before_action) && !before_action.nil?
  end
  context "I have sufficient rights" do
    it "should let me to it" do
      login_user(:user => authorized_user, :mock => false, :superuser => false)
      @controller.should_not_receive(:render_403)
      before_success_action if defined?(before_success_action) && !before_success_action.nil?
      req
      on_success if defined?(on_success) && !on_success.nil?
    end
  end

  context "I have not sufficient rights" do
    it "should not let me to it" do
      login_user(:user => unauthorized_user, :mock => false, :superuser => false)
      @controller.should_receive(:render_403)
      before_fail_action if defined?(before_fail_action) && !before_fail_action.nil?
      req
      on_failure if defined?(on_failure) && !on_failure.nil?
    end
  end
end


