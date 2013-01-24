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

describe Api::TemplatesController, :katello => true do
  include LoginHelperMethods
  include AuthorizationHelperMethods
  include LocaleHelperMethods

  TEMPLATE_ID = 1
  TEMPLATE_NAME = "template"

  before(:each) do
    @organization = Organization.new(:name => 'organization', :label=>"organization")
    @organization.id = 1

    @environment = KTEnvironment.new(:name=>'environment', :label=> 'environment', :library => false)
    @environment.id = 1
    @environment2 = KTEnvironment.new(:name=>'environment2', :label => 'environment2')
    @environment2.id = 3
    @library = KTEnvironment.new(:name => 'Library', :library => true, :label => 'library')
    @library.id = 2
    KTEnvironment.stub(:find).with(@library.id).and_return(@library)
    KTEnvironment.stub(:find).with(@environment.id).and_return(@environment)
    KTEnvironment.stub(:find).with(@environment2.id).and_return(@environment2)

    @organization.library = @library
    @organization.environments << @library
    @organization.environments << @environment

    @tpl = SystemTemplate.new(:name => TEMPLATE_NAME, :environment => @library)
    SystemTemplate.stub(:find).and_return(@tpl)
    SystemTemplate.stub(:new).and_return(@tpl)

    @request.env["HTTP_ACCEPT"] = "application/json"
    login_user_api
    set_default_locale
  end

  let(:to_create) do
    {
      :name => TEMPLATE_NAME,
      :description => "a description"
    }
  end
  let(:new_tpl_name) {"changed_"+TEMPLATE_NAME}



  describe "rules" do
    let(:user_with_read_permissions) do
      user_with_permissions { |u| u.can(:read_all, :system_templates, nil, @organization) }
    end
    let(:user_with_manage_permissions) do
      user_with_permissions { |u| u.can(:manage_all, :system_templates, nil, @organization) }
    end
    let(:unauthorized_user) do
      user_without_permissions
    end
    describe "index" do
      let(:action) { :index }
      let(:req) do
        get 'index', :environment_id => @library.id
      end
      let(:authorized_user) { user_with_read_permissions }
      it_should_behave_like "protected action"
    end
    describe "show" do
      let(:action) { :show }
      let(:req) do
        get :show, :id => TEMPLATE_ID
      end
      let(:authorized_user) { user_with_read_permissions }
      it_should_behave_like "protected action"
    end
    describe "create" do
      let(:action) {:create}
      let(:req) do
        post 'create', :template => to_create, :environment_id => @library.id
      end
      let(:authorized_user) { user_with_manage_permissions }
      it_should_behave_like "protected action"
    end
    describe "update" do
      let(:action) {:update}
      let(:req) do
        put 'update', :id => TEMPLATE_ID, :template => {:name => new_tpl_name, :description => "new_description"}
      end
      let(:authorized_user) { user_with_manage_permissions }
      it_should_behave_like "protected action"
    end
    describe "destroy" do
      let(:action) {:destroy}
      let(:req) do
        delete :destroy, :id => TEMPLATE_ID
      end
      let(:authorized_user) { user_with_manage_permissions }
      it_should_behave_like "protected action"
    end
    describe "validate" do
      let(:action) { :validate }
      let(:req) do
        get :validate, :id => TEMPLATE_ID
      end
      let(:authorized_user) { user_with_read_permissions }
      it_should_behave_like "protected action"
    end
    describe "import" do
      before(:each) do
        @temp_file = mock(File)
        @temp_file.stub(:read).and_return('FILE_DATA')
        @temp_file.stub(:close)
        @temp_file.stub(:write)
        @temp_file.stub(:path).and_return("/a/b/c")

        File.stub(:new).and_return(@temp_file)
        KTEnvironment.stub(:find).and_return(@library)
      end
      let(:action) {:import}
      let(:req) do
        post :import, :template_file => @temp_file, :environment_id => @library.id
      end
      let(:authorized_user) { user_with_manage_permissions }
      it_should_behave_like "protected action"
    end
    describe "export" do
      let(:action) { :export }
      let(:req) do
        get :export, :id => TEMPLATE_ID
      end
      let(:authorized_user) { user_with_read_permissions }
      it_should_behave_like "protected action"
    end
  end

  describe "tests" do
    describe "index" do

      before :each do
        disable_authorization_rules
      end

      it 'should get a list of templates from specified environment' do
        tpl_selection_mock = mock('where')
        tpl_selection_mock.stub(:where).and_return([@tpl])
        @library.should_receive(:system_templates).and_return(tpl_selection_mock)
        get 'index', :environment_id => @library.id
        response.should be_success
      end

      it 'should not fail if no templates are found, but return an empty list' do
        tpl_selection_mock = mock('where')
        tpl_selection_mock.stub(:where).and_return([])
        @environment2.should_receive(:system_templates).and_return(tpl_selection_mock)

        get 'index', :environment_id => @environment2.id
        response.should be_success
      end
    end


    describe "show" do
      it "should call SystemTemplate.first" do
        SystemTemplate.should_receive(:find).with(TEMPLATE_ID).and_return(@tpl)
        get :show, :id => TEMPLATE_ID
      end
    end


    describe "create" do
      it_should_behave_like "bad request"  do
        let(:req) do
          bad_req = {:organization_id => @organization.name,
                     :template =>
                        {:bad_foo => "mwahahaha",
                         :name => "Gpg Key",
                         :description => "This is the key string" }
          }.with_indifferent_access
          post :create, bad_req
        end
      end

      it "should fail when creating in non-library environment" do
        post 'create', :template => to_create, :environment_id => @environment.id
        SystemTemplate.should_not_receive(:new)
        response.should_not be_success
      end

      it "should call new and save!" do
        KTEnvironment.stub(:find).and_return(@library)

        SystemTemplate.should_receive(:new).and_return(@tpl)
        @tpl.should_receive(:save!)

        post 'create', :template => to_create, :environment_id => @library.id
      end
    end


    describe "update" do
      it "should fail when updating in non-library environment" do
        @tpl.environment = @environment
        @tpl.should_not_receive(:save!)

        put 'update', :id => TEMPLATE_ID

        response.should_not be_success
      end

      it 'should update template in the Library' do
        @tpl.stub(:get_clones).and_return([])
        @tpl.should_receive(:save!).once

        put 'update', :id => TEMPLATE_ID, :template => {:name => new_tpl_name, :description => "new_description"}

        response.should be_success
      end

      it 'should change name of all template clones when updating template in the Library' do
        tpl_clone = SystemTemplate.new(:name => TEMPLATE_NAME, :environment => @environment)
        tpl_clone.should_receive(:save!).once

        @tpl.stub(:get_clones).and_return([tpl_clone])
        @tpl.should_receive(:save!).once

        put 'update', :id => TEMPLATE_ID, :template => {:name => new_tpl_name, :description => "new_description"}

        tpl_clone.name.should == new_tpl_name
        response.should be_success
      end

      it_should_behave_like "bad request"  do
        let(:req) do
          bad_req = {:id => TEMPLATE_ID,
                     :template =>
                        {:bad_foo => "mwahahaha",
                         :name => "Gpg Key",
                         :description => "This is the key string" }
          }.with_indifferent_access
          put :update, bad_req
        end
      end

    end

    describe "destroy" do
      it "should remove the specified template" do
        SystemTemplate.should_receive(:find).with(TEMPLATE_ID).and_return(@tpl)
        @tpl.should_receive(:destroy).once

        delete :destroy, :id => TEMPLATE_ID
      end
    end


    describe "import" do
      before(:each) do
        @temp_file = mock(File)
        @temp_file.stub(:read).and_return('FILE_DATA')
        @temp_file.stub(:close)
        @temp_file.stub(:write)
        @temp_file.stub(:path).and_return("/a/b/c")

        File.stub(:new).and_return(@temp_file)
        KTEnvironment.stub(:find).and_return(@library)
      end

      it "should fail when imporing into non-library environment" do
        post :import, :template_file => @temp_file, :environment_id => @environment.id
        response.should_not be_success
      end

      it "should call import" do
        SystemTemplate.should_receive(:new).and_return(@tpl)
        @tpl.should_receive(:import).once

        post :import, :template_file => @temp_file, :environment_id => @library.id
      end
    end


    describe "export" do
      it "should call export_as_json" do
        @tpl.environment = @environment
        @tpl.should_receive(:export_as_json)

        get :export, :id => TEMPLATE_ID
      end

      it "should call export_as_tdl" do
        @tpl.environment = @environment
        @tpl.should_receive(:export_as_tdl)

        get :export, :id => TEMPLATE_ID, :format => 'tdl'
      end

      it "should raise an exception when exporting from a Library" do

        get :export, :id => TEMPLATE_ID
        response.should_not be_success
      end

    end
  end
end
