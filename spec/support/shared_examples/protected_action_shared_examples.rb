#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You must
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require "test_helper"

def login_user_by_described_class(user)
=begin
  if described_class.name =~ /^Api::/
    login_user_api(user)
  else
    login_user(:user => user, :mock => false, :superuser => false)
  end
=end
  User.current = user
end

shared_examples_for "protected action" do
  describe "ALLOWING me" do
    it "to it (katello)" do #TODO headpin
      if !defined?(on_success) && !defined?(before_success)
        @controller.stubs(action)
        @controller.stubs(:render)
      end

      login_user_by_described_class(authorized_user) if defined?  authorized_user
      before_success if defined?(before_success)

      if @controller.kind_of? Katello::Api::V1::ApiController
        @controller.expects(:respond_for_exception).with { |e, options| options.try(:[], :status).must == :forbidden }
      else
        @controller.expects(:render_403)
      end

      req
      on_success if defined?(on_success)

      response.must be_success

      if respond_to? :authorized_user
        ::Logging.logger['roles'].debug(
            '||!%s||%s||!%s||' %
                [@controller.class.name, action, authorized_user.own_role.permissions.map(&:to_short_text).inspect])
      end
    end
  end
  describe "NOT ALLOWING me" do
    it "to it (katello)" do #TODO headpin
      if defined? unauthorized_user
        if !defined?(on_success) && !defined?(before_success)
          @controller.stubs(action)
          @controller.stubs(:render)
        end
        session.delete(:current_organization_id)
        login_user_by_described_class(unauthorized_user) if defined?  unauthorized_user
        before_failure if defined?(before_failure)
        if @controller.kind_of? Katello::Api::V1::ApiController
          @controller.expects(:respond_for_exception).with { |e, options| options.try(:[], :status).must == :forbidden }
        else
          @controller.expects(:render_403)
        end

        req
        on_failure if defined?(on_failure)
      end
    end
  end
end

shared_examples_for "bad request" do
  describe "action" do
    it "must fail (katello)" do #TODO headpin
      req
      response.status.must == HttpErrors::UNPROCESSABLE_ENTITY
    end
  end
end
