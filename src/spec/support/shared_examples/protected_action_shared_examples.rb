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


def login_user_by_described_class(user)
  if described_class.name =~ /^Api::/
    login_user_api(user)
  else
    login_user(:user => user, :mock => false, :superuser => false)
  end
end

shared_examples_for "protected action" do
  before(:each) do
    # it takes action from describe method
  end
  context "ALLOWING me" do
    it "to it", :katello => true do #TODO headpin
      if !defined?(on_success) && !defined?(before_success)

        controller.stub(action)
        controller.stub(:render)
      end
      login_user_by_described_class(authorized_user) if defined?  authorized_user
      before_success if defined?(before_success)

      if controller.kind_of? Api::V1::ApiController
        controller.should_not_receive(:render_exception_without_logging).with { |status, e| status.should == 403 }
      else
        controller.should_not_receive(:render_403)
      end

      req
      on_success if defined?(on_success)


      response.should be_success

      if respond_to? :authorized_user
        ::Logging.logger['roles'].debug(
            '||!%s||%s||!%s||' %
                [controller.class.name, action, authorized_user.own_role.permissions.map(&:to_short_text).inspect])
      end
    end
  end
  context "NOT ALLOWING me" do
    it "to it", :katello => true do #TODO headpin
      if !defined?(on_success) && !defined?(before_success)
        @controller.stub(action)
        @controller.stub(:render)
      end
      session.delete(:current_organization_id)
      login_user_by_described_class(unauthorized_user) if defined?  unauthorized_user
      before_failure if defined?(before_failure)
      if @controller.kind_of? Api::V1::ApiController
        @controller.should_receive(:render_exception_without_logging).with { |status, e| status.should == 403 }
      else
        @controller.should_receive(:render_403)
      end

      req
      on_failure if defined?(on_failure)
    end
  end
end


shared_examples_for "bad request" do
  context "action" do
    it "should fail", :katello => true do #TODO headpin
      req
      response.status.should == HttpErrors::UNPROCESSABLE_ENTITY
    end
  end
end
