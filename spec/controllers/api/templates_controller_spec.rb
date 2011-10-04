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

describe Api::TemplatesController do
  include LoginHelperMethods

  TEMPLATE_ID = 1
  TEMPLATE_NAME = "template"

  before(:each) do
    @organization = Organization.new(:name => 'organization', :cp_key => 'organization')
    @organization.id = 1

    @environment = KTEnvironment.new(:name => 'environment', :locker => false)
    @environment.id = 1
    @locker = KTEnvironment.new(:name => 'Locker', :locker => true)
    @locker.id = 2

    @organization.locker = @locker
    @organization.environments << @locker
    @organization.environments << @environment

    @tpl = SystemTemplate.new(:name => TEMPLATE_NAME, :environment => @locker)
    SystemTemplate.stub(:find).and_return(@tpl)
    SystemTemplate.stub(:new).and_return(@tpl)

    @request.env["HTTP_ACCEPT"] = "application/json"
    login_user_api
  end

  let(:to_create) do
    {
      :name => TEMPLATE_NAME,
      :description => "a description"
    }
  end

  describe "index" do

    before :each do
      @environment2 = KTEnvironment.new(:name => 'environment2')
      @environment2.id = 3

      KTEnvironment.stub(:find).with(@locker.id).and_return(@locker)
      KTEnvironment.stub(:find).with(@environment2.id).and_return(@environment2)

    end

    it 'should get a list of templates from specified environment' do
      tpl_selection_mock = mock('where')
      tpl_selection_mock.stub(:where).and_return([@tpl])
      @locker.should_receive(:system_templates).and_return(tpl_selection_mock)
      get 'index', :environment_id => @locker.id
      response.should be_success
    end

    it 'should get a list of all templates' do
      SystemTemplate.should_receive(:where).and_return([@tpl])
      get 'index'
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

    it "should fail when creating in non-locker environment" do
      post 'create', :template => to_create, :environment_id => @environment.id
      SystemTemplate.should_not_receive(:new)
      response.should_not be_success
    end

    it "should call new and save!" do
      KTEnvironment.stub(:find).and_return(@locker)

      SystemTemplate.should_receive(:new).and_return(@tpl)
      @tpl.should_receive(:save!)

      post 'create', :template => to_create, :environment_id => @locker.id
    end
  end


  describe "update" do
    let(:new_tpl_name) {"changed_"+TEMPLATE_NAME}

    it "should fail when updating in non-locker environment" do
      @tpl.environment = @environment
      @tpl.should_not_receive(:save!)

      put 'update', :id => TEMPLATE_ID

      response.should_not be_success
    end

    it 'should update template in the Locker' do
      @tpl.stub(:get_clones).and_return([])
      @tpl.should_receive(:save!).once

      put 'update', :id => TEMPLATE_ID, :template => {:name => new_tpl_name, :description => "new_description"}

      response.should be_success
    end

    it 'should change name of all template clones when updating template in the Locker' do
      tpl_clone = SystemTemplate.new(:name => TEMPLATE_NAME, :environment => @environment)
      tpl_clone.should_receive(:save!).once

      @tpl.stub(:get_clones).and_return([tpl_clone])
      @tpl.should_receive(:save!).once

      put 'update', :id => TEMPLATE_ID, :template => {:name => new_tpl_name, :description => "new_description"}

      tpl_clone.name.should == new_tpl_name
      response.should be_success
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
      KTEnvironment.stub(:find).and_return(@locker)
    end

    it "should fail when imporing into non-locker environment" do
      post :import, :template_file => @temp_file, :environment_id => @environment.id
      response.should_not be_success
    end

    it "should call import" do
      SystemTemplate.should_receive(:new).and_return(@tpl)
      @tpl.should_receive(:import).once

      post :import, :template_file => @temp_file, :environment_id => @locker.id
    end
  end


  describe "export" do
    it "should call export" do
      @tpl.should_receive(:string_export)

      get :export, :id => TEMPLATE_ID
    end
  end


  describe "promote" do
    before(:each) do
      @async_proxy = mock(AsyncOrchestration::AsyncOrchestrationProxy)
    end

    it "should call SystemTemplate#promote" do
      @tpl.should_receive(:async).once.with(hash_including(:organization => @organization)).and_return(@async_proxy)
      @async_proxy.should_receive(:promote).once.with(no_args())
      post :promote, :id => TEMPLATE_ID
    end
  end


end
