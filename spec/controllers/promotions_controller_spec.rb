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

require 'katello_test_helper'

module Katello
  describe PromotionsController do
    include LocaleHelperMethods
    include OrchestrationHelper
    include OrganizationHelperMethods
    include ProductHelperMethods
    include AuthorizationHelperMethods

    describe "(katello)" do

      describe "Getting the promotions page " do

        before (:each) do
          setup_controller_defaults
          @org = new_test_org
          @controller.stubs(:current_organization).returns(@org)
          Glue::Pulp::Repos.stubs(:prepopulate!).returns([])
          @env = @org.library

        end

        it "should be successful with library and no next environment" do
          get 'show', :id => @env.name

          must_respond_with(:success)

          assigns(:environment).must_equal @env
          assigns(:next_environment).must_equal nil
        end

        it "should be successful on the library and a next environment" do
          @env2 = KTEnvironment.new(:organization => @org, :label => "otherenv", :library => false, :name => "otherenv", :prior => @org.library)
          @env2.save!
          get 'show', :id => @env.name
          must_respond_with(:success)
          assigns(:next_environment).must_equal @env2
          assigns(:environment).must_equal @env
          assigns(:path).wont_be_nil
        end

        it "should be successful on the next environment with no changeset" do
          @env2 = KTEnvironment.new(:organization => @org, :label => "otherenv", :library => false, :name => "otherenv", :prior => @org.library)
          @env2.save!
          get 'show', :id => @env2.name
          must_respond_with(:success)
          assigns(:environment).must_equal @env2
          assigns(:next_environment).must_equal nil
        end

      end

      describe "rules" do
        before (:each) do
          setup_controller_defaults
          @organization = new_test_org
          @controller.stubs(:current_organization).returns(@organization)
          @env1 = @organization.library
          @env2 = create_environment(:name => "FOO", :label => "FOO", :prior => @env1, :organization => @organization)
          @env3 = create_environment(:name => "FOO2", :label => "FOO2", :prior => @env2, :organization => @organization)
          Glue::Pulp::Repos.stubs(:prepopulate!).returns([])
        end

        describe "GET index with changesets readable" do
          let(:req) { get 'show' }
          let(:action) { :show }
          let(:authorized_user) do
            user_with_permissions { |u| u.can(:read_changesets, :environments, @env3.id, @organization) }
          end
          let(:unauthorized_user) do
            user_without_permissions
          end
          let(:on_success) do
            assigns(:environment).must_equal @env2
            assigns(:next_environment).must_equal @env3
          end
          it_should_behave_like "protected action"
        end

        describe "GET index with contents readable" do
          let(:req) { get 'show' }
          let(:action) { :show }
          let(:authorized_user) do
            user_with_permissions { |u| u.can(:read_contents, :environments, @env2.id, @organization) }
          end
          let(:unauthorized_user) do
            user_without_permissions
          end
          let(:on_success) do
            assigns(:environment).must_equal @env2
            assigns(:next_environment).must_equal @env3
          end
          it_should_behave_like "protected action"
        end

        describe 'examining locals' do
          describe "apply" do
            shared_examples_for "promotion page perm checks" do
              it "test action" do
                set_user(authorized_user)
                get 'show', { :id => env.name }
                on_show
              end
            end

            describe "read contents" do
              let(:env) { @env1 }
              let(:authorized_user) do
                user_with_permissions { |u| u.can(:read_contents, :environments, @env1.id, @organization) }
              end
              let(:on_show) {
                must_respond_with(:success)
                assigns[:locals_hash]["read_contents"].must_equal true
                assigns[:locals_hash]["read_promotion_changesets"].must_equal false
                assigns[:locals_hash]["read_deletion_changesets"].must_equal false
                assigns[:locals_hash]["manage_promotion_changesets"].must_equal false
                assigns[:locals_hash]["manage_deletion_changesets"].must_equal false
                assigns[:locals_hash]["apply_promotion_changesets"].must_equal false
                assigns[:locals_hash]["apply_deletion_changesets"].must_equal false
              }
              it_should_behave_like "promotion page perm checks"
            end

            describe "user with promotion perms" do
              let(:env) { @env1 }
              let(:authorized_user) do
                user_with_permissions { |u| u.can(:promote_changesets, :environments, @env2.id, @organization) }
              end
              let(:on_show) {
                must_respond_with(:success)
                assigns[:locals_hash]["read_contents"].must_equal(false)
                assigns[:locals_hash]["read_promotion_changesets"].must_equal(true)
                assigns[:locals_hash]["read_deletion_changesets"].must_equal(false)
                assigns[:locals_hash]["manage_promotion_changesets"].must_equal(false)
                assigns[:locals_hash]["manage_deletion_changesets"].must_equal(false)
                assigns[:locals_hash]["apply_promotion_changesets"].must_equal(true)
                assigns[:locals_hash]["apply_deletion_changesets"].must_equal(false)
              }
              it_should_behave_like "promotion page perm checks"
            end

            describe "user with deletion perms" do
              let(:env) { @env2 }
              let(:authorized_user) do
                user_with_permissions { |u| u.can(:delete_changesets, :environments, @env2.id, @organization) }
              end
              let(:on_show) {
                must_respond_with(:success)
                assigns[:locals_hash]["read_contents"].must_equal(false)
                assigns[:locals_hash]["read_promotion_changesets"].must_equal(false)
                assigns[:locals_hash]["read_deletion_changesets"].must_equal(true)
                assigns[:locals_hash]["manage_promotion_changesets"].must_equal(false)
                assigns[:locals_hash]["manage_deletion_changesets"].must_equal(false)
                assigns[:locals_hash]["apply_promotion_changesets"].must_equal(false)
                assigns[:locals_hash]["apply_deletion_changesets"].must_equal(true)
              }
              it_should_behave_like "promotion page perm checks"
            end
          end

        end
      end
    end
  end
end
