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
    @organization = Organization.new
    @organization.id = 1

    @environment = KPEnvironment.new
    @environment.id = 1
    @locker = KPEnvironment.new
    @locker.id = 2

    @organization.locker = @locker
    @organization.environments << @environment

    @tpl = SystemTemplate.new(:name => TEMPLATE_NAME, :environment => @environment)
    SystemTemplate.stub(:find).and_return(@tpl)
    SystemTemplate.stub(:new).and_return(@tpl)

   # KPEnvironment.stub(:find).with(@environment.id).and_return(@environment)
   # KPEnvironment.stub(:find).with(@locker.id).and_return(@locker)


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
    it 'should call where with query params' do
      SystemTemplate.should_receive(:where).once
      get 'index'
    end
  end


  describe "show" do
    it "should call SystemTemplate.first" do
      SystemTemplate.should_receive(:find).with(TEMPLATE_ID).and_return(@tpl)
      get :show, :id => TEMPLATE_ID
    end
  end


  describe "create" do
    it "should call new and save!" do
      KPEnvironment.stub(:find).and_return(@environment)

      SystemTemplate.should_receive(:new).and_return(@tpl)
      @tpl.should_receive(:save!)

      post 'create', :template => to_create, :environment_id => @environment.id
    end
  end


  describe "update" do
    it 'should call update_attributes' do
      #KPEnvironment.should_receive(:find).and_return(@environment)
      #KPEnvironment.stub(:find).and_return(@environment)

      @tpl.should_receive(:update_attributes!).once
      put 'update', :id => TEMPLATE_ID, :template => {}
    end
  end


  describe "update_content" do

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
      KPEnvironment.stub(:find).and_return(@environment)
    end

    it "should call import" do
      SystemTemplate.should_receive(:new).and_return(@tpl)
      @tpl.should_receive(:import).once

      post :import, :template_file => @temp_file, :environment_id => @environment.id
    end
  end


  describe "export" do
    it "should call export" do
      @tpl.should_receive(:string_export)

      get :export, :id => TEMPLATE_ID
    end
  end


  describe "promote" do
    it "should call SystemTemplate#promote" do
      @tpl.should_receive(:promote).once

      post :promote, :id => TEMPLATE_ID
    end
  end


end
