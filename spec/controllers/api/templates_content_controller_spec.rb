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

require 'spec_helper.rb'

#def self.it_should_require_admin_for_actions(*actions)
#  actions.each do |action|
#    it "#{action} action should require admin" do
#      get action, :id => 1
#      response.should redirect_to(login_url)
#      flash[:error].should == "Unauthorized Access"
#    end
#  end
#end

def should_fail_in_non_library_env method
  it "should fail when editing a template in a non-library environment" do
    SystemTemplate.should_receive(:find).with(non_library_template_id)
    post   method, :template_id => non_library_template_id             if method.to_s.match(/^add_/)
    delete method, :template_id => non_library_template_id, :id => 123 if method.to_s.match(/^remove_/)
    response.should_not be_success
  end
end

describe Api::TemplatesContentController do
  include LoginHelperMethods
  include AuthorizationHelperMethods

  let(:template_id) { 1 }
  let(:non_library_template_id) { 2 }
  let(:product_cp_id) { 123456 }
  let(:package_name) { "package-x.y-z" }
  let(:package_group_name) { "package_group" }
  let(:package_group_cat_name) { "package_group_cat" }
  let(:param_name) { "parameter_1" }
  let(:param_value) { "value_1" }
  let(:distribution_id) { 1 }

  before(:each) do
    @organization = Organization.new(:name => 'organization', :label => 'organization')
    @organization.id = 1

    @environment = KTEnvironment.new(:name=>'environment', :label=> 'environment', :library => false)
    @environment.id = 1
    @environment.stub(:library?).and_return(false)
    @library = KTEnvironment.new(:name=>'Library', :label=> 'Library', :library => true)
    @library.id = 2
    @library.stub(:library?).and_return(true)

    @organization.library = @library
    @organization.environments << @library
    @organization.environments << @environment

    @tpl = SystemTemplate.new(:name => "template", :environment => @library, :id => template_id)
    SystemTemplate.stub(:find).with(template_id).and_return(@tpl)

    @tpl_clone = SystemTemplate.new(:name => "template", :environment => @environment, :id => non_library_template_id)
    SystemTemplate.stub(:find).with(non_library_template_id).and_return(@tpl_clone)

    @request.env["HTTP_ACCEPT"] = "application/json"
    login_user_api
  end

  describe "rules" do
    let(:authorized_user) do
      user_with_permissions { |u| u.can(:manage_all, :system_templates, nil, @organization) }
    end
    let(:unauthorized_user) do
      user_without_permissions
    end
    #bz 799149
    #describe "for add_product" do
    #  let(:action) { :add_product }
    #  let(:req) do
    #    post :add_product, :template_id => template_id, :id => product_cp_id
    #  end
    #  it_should_behave_like "protected action"
    #end
    #describe "for remove_product" do
    #  let(:action) { :remove_product }
    #  let(:req) do
    #    post :remove_product, :template_id => template_id, :id => product_cp_id
    #  end
    #  it_should_behave_like "protected action"
    #end
    describe "for add_package" do
      let(:action) { :add_package }
      let(:req) do
        post :add_package, :template_id => template_id, :name => package_name
      end
      it_should_behave_like "protected action"
    end
    describe "for remove_package" do
      let(:action) { :remove_package }
      let(:req) do
        delete :remove_package, :template_id => template_id, :id => package_name
      end
      it_should_behave_like "protected action"
    end
    describe "for add_parameter" do
      let(:action) { :add_parameter }
      let(:req) do
        post :add_parameter, :template_id => template_id, :name => param_name, :value => param_value
      end
      it_should_behave_like "protected action"
    end
    describe "for remove_parameter" do
      let(:action) { :remove_parameter }
      let(:req) do
        delete :remove_parameter, :template_id => template_id, :id => param_name
      end
      it_should_behave_like "protected action"
    end
    describe "for add_package_group" do
      let(:action) { :add_package_group }
      let(:req) do
        post :add_package_group, :template_id => template_id, :name => package_group_name
      end
      it_should_behave_like "protected action"
    end
    describe "for remove_package_group" do
      let(:action) { :remove_package_group }
      let(:req) do
        delete :remove_package_group, :template_id => template_id, :id => package_group_name
      end
      it_should_behave_like "protected action"
    end
    describe "for add_package_group_category" do
      let(:action) { :add_package_group_category }
      let(:req) do
        post :add_package_group_category, :template_id => template_id, :name => package_group_cat_name
      end
      it_should_behave_like "protected action"
    end
    describe "for remove_package_group_category" do
      let(:action) { :remove_package_group_category }
      let(:req) do
        delete :remove_package_group_category, :template_id => template_id, :id => package_group_cat_name
      end
      it_should_behave_like "protected action"
    end
    describe "for add_distribution" do
      let(:action) { :add_distribution }
      let(:req) do
        post :add_distribution, :template_id => template_id, :id => distribution_id
      end
      it_should_behave_like "protected action"
    end
    describe "for remove_distribution" do
      let(:action) { :remove_distribution }
      let(:req) do
        delete :remove_distribution, :template_id => template_id, :id => distribution_id
      end
      it_should_behave_like "protected action"
    end
  end

  describe "tests" do
    before(:each) do
      disable_authorization_rules
    end

    # bz 799149
    #describe "update products" do
    #
    #  should_fail_in_non_library_env :add_product
    #  should_fail_in_non_library_env :remove_product
    #
    #  it "should add product" do
    #    @tpl.should_receive(:add_product_by_cpid).with(product_cp_id).and_return(true)
    #
    #    post :add_product, :template_id => template_id, :id => product_cp_id
    #    response.should be_success
    #  end
    #
    #  it "should remove product" do
    #    @tpl.should_receive(:remove_product_by_cpid).with(product_cp_id).and_return(true)
    #
    #    delete :remove_product, :template_id => template_id, :id => product_cp_id
    #    response.should be_success
    #  end
    #
    #end

    describe "update packages" do

      should_fail_in_non_library_env :add_package
      should_fail_in_non_library_env :remove_package

      it "should add package" do
        @tpl.should_receive(:add_package).with(package_name).and_return(true)

        post :add_package, :template_id => template_id, :name => package_name
        response.should be_success
      end

      it "should remove package" do
        @tpl.should_receive(:remove_package).with(package_name).and_return(true)

        delete :remove_package, :template_id => template_id, :id => package_name
        response.should be_success
      end

    end

    describe "update package groups" do

      should_fail_in_non_library_env :add_package_group
      should_fail_in_non_library_env :remove_package_group

      it "should add package group" do
        @tpl.should_receive(:add_package_group).with(package_group_name).and_return(true)

        post :add_package_group, :template_id => template_id, :name => package_group_name
        response.should be_success
      end

      it "should remove package group" do
        @tpl.should_receive(:remove_package_group).with(package_group_name).and_return(true)

        delete :remove_package_group, :template_id => template_id, :id => package_group_name
        response.should be_success
      end

    end

    describe "update package group categories" do

      should_fail_in_non_library_env :add_package_group_category
      should_fail_in_non_library_env :remove_package_group_category

      it "should add package group category" do
        @tpl.should_receive(:add_pg_category).with(package_group_cat_name).and_return(true)

        post :add_package_group_category, :template_id => template_id, :name => package_group_cat_name
        response.should be_success
      end

      it "should remove package group category" do
        @tpl.should_receive(:remove_pg_category).with(package_group_cat_name).and_return(true)

        delete :remove_package_group_category, :template_id => template_id, :id => package_group_cat_name
        response.should be_success
      end

    end

    describe "update parameters" do

      should_fail_in_non_library_env :add_parameter
      should_fail_in_non_library_env :remove_parameter

      it "should add a parameter" do
        @tpl.should_receive(:set_parameter).with(param_name, param_value).and_return(true)

        post :add_parameter, :template_id => template_id, :name => param_name, :value => param_value
        response.should be_success
      end

      it "should remove a parameter" do
        @tpl.should_receive(:remove_parameter).with(param_name).and_return(true)

        delete :remove_parameter, :template_id => template_id, :id => param_name
        response.should be_success
      end

    end
  end

end
