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

    it 'should get a list of templates from specified environment ID' do
      SystemTemplate.should_receive(:where).with("environment_id" => @locker.id).and_return([@tpl])
      get 'index', :environment_id => @locker.id
      response.should be_success
    end

    it 'should not fail if no templates are found, but return an empty list' do
      @environment2 = KTEnvironment.new(:name => 'environment2')
      @environment2.id = 3

      SystemTemplate.should_receive(:where).with("environment_id" => @environment2.id).and_return([])
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
    it "should fail when updating in non-locker environment" do
      @tpl.environment = @environment
      put 'update_content', :id => TEMPLATE_ID
      @tpl.should_not_receive(:update_attributes!)
      response.should_not be_success
    end

    it 'should call update_attributes' do
      @tpl.should_receive(:update_attributes!).once
      put 'update', :id => TEMPLATE_ID, :template => {}
    end
  end


  describe "update_content" do

    it "should fail when updating in non-locker environment" do
      @tpl.environment = @environment
      put 'update_content', :id => TEMPLATE_ID
      response.should_not be_success
    end

    it 'should call add_product' do
      @tpl.should_receive(:add_product).once
      put 'update_content', :id => TEMPLATE_ID, :do => :add_product
    end

    it 'should call remove_product' do
      @tpl.should_receive(:remove_product).once
      put 'update_content', :id => TEMPLATE_ID, :do => :remove_product
    end

    it 'should call add_package' do
      @tpl.should_receive(:add_package).once
      put 'update_content', :id => TEMPLATE_ID, :do => :add_package
    end

    it 'should call remove_package' do
      @tpl.should_receive(:remove_package).once
      put 'update_content', :id => TEMPLATE_ID, :do => :remove_package
    end

    it 'should call add_erratum' do
      @tpl.should_receive(:add_erratum).once
      put 'update_content', :id => TEMPLATE_ID, :do => :add_erratum
    end

    it 'should call remove_erratum' do
      @tpl.should_receive(:remove_erratum).once
      put 'update_content', :id => TEMPLATE_ID, :do => :remove_erratum
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
