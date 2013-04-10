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

require 'spec_helper'

describe Resources::ForemanModel do

  let(:resource) { mock('resource') }
  let(:klass) { Resources::ForemanModel }
  let(:instance) { klass.new }

  before { klass.resource resource }
  after { klass.resource nil }

  subject { klass }

  it "should have attribute :id" do
    subject.attributes.should =~ [:id]
  end

  describe 'instance' do
    subject { instance }

    describe '#resource' do
      subject { instance.resource }
      it { should == resource }
    end

    describe 'when not persisted' do
      it { should_not be_persisted }
      it 'should create' do
        subject.should_receive :create
        subject.save
      end
    end

    describe 'when persisted' do
      before { subject.send :set_as_persisted }

      it { should be_persisted }
      it 'should update' do
        subject.should_receive :update
        subject.save
      end
    end


  end

  describe 'a child klass' do
    let(:klass) do
      that = self
      Class.new(Resources::ForemanModel) do
        def self.name # for inflections to work
          'AChildKlass'
        end

        def id_name
          "#{id}-#{name}"
        end

        def json_default_options
          { :only => [:name], :methods => [:id_name] }
        end

        resource_name 'a_child_klass'

        self.current_user_getter = lambda { that.mock('user', :username => 'username') }

        attributes :name
        validates :name, :presence => true
      end
    end

    it "should have attributes :id, :name" do
      subject.attributes.should =~ [:id, :name]
    end

    describe '.find!' do
      before do
        resource.
            should_receive(:show).
            with({ 'id' => 3 }, klass.header).
            and_return [{ 'a_child_klass' => { 'name' => subject.name, 'id' => 3, 'other' => 'data' } },
                        mock('response')]
      end

      let(:finding) { klass.find! 3 }

      it { lambda { finding }.should_not raise_error }
      it { finding.should_not be_nil }
      it { finding.should be_kind_of(klass) }
      it { finding.should be_persisted }
    end

    describe '.all' do
      let(:params) { mock('params') }
      before do
        resource.
            should_receive(:index).
            with(params, klass.header).
            and_return [[{ 'a_child_klass' => { 'name' => subject.name, 'id' => 3, 'other' => 'data' } },
                         { 'a_child_klass' => { 'name' => subject.name, 'id' => 3, 'other' => 'data' } }],
                        mock('response')]
      end

      let(:retrieving_all) { klass.all params }

      it { lambda { retrieving_all }.should_not raise_error }
      it { retrieving_all.should_not be_empty }
      it('should all be kind of resource') { retrieving_all.should be_all { |o| o.kind_of?(klass) } }
      it('should all be persisted') { retrieving_all.should be_all { |o| o.persisted? } }
    end



    describe 'instance' do
      let(:instance_id) { 3 }
      let(:instance_name) { 'Invisible man' }
      let :persisted_instance do
        persisted = instance.clone
        persisted.id = instance_id
        persisted.send :set_as_persisted
        persisted
      end

      subject { instance }

      describe '#resource' do
        subject { instance.resource }
        it { should == resource }
      end

      describe 'without name' do
        it { should_not be_valid }

        it "should have error on name" do
          subject.valid?
          subject.errors[:name].should_not be_empty
        end
      end

      describe 'with name' do
        before { subject.attributes = { :id => instance_id, :name => instance_name } }
        it { should be_valid }

        it "should serialize" do
          subject.as_json.should == { 'a_child_klass' => { 'name' => subject.name, :id_name => subject.id_name } }
        end
      end

      describe '.to_key' do
        describe 'on unsaved instance' do
          it("should return nil") { subject.to_key.should be_nil }
        end

        describe 'on saved instance' do
          subject { persisted_instance }

          it("should return array") { subject.to_key.kind_of? Array }
          it("should return array of length 1") { subject.to_key.length.should == 1 }
          it("should return id") { subject.to_key[0].should == instance_id }
        end
      end

      describe '.to_param' do
        describe 'on unsaved instance' do
          it("should return nil") { subject.to_key.should be_nil }
        end

        describe 'on saved instance' do
          subject { persisted_instance }

          it("should return string") { subject.to_param.kind_of? String }
          it("should return string with id") { subject.to_param.should == instance_id.to_s }
        end
      end

      describe 'when updating attributes' do
        let(:new_name) { 'William Blake' }
        let(:new_valid_attrs) {{ :name => new_name }}
        let(:new_invalid_attrs) {{ :name => nil }}
        let(:name_attribute) { instance.attributes.symbolize_keys[:name] }

        before do
          subject.name = instance_name
          subject.stub(:save).and_return(true)
          subject.stub(:save!).and_return(true)
        end

        describe "with valid values" do

          let(:update) {subject.update_attributes new_valid_attrs}
          let(:update!) {subject.update_attributes! new_valid_attrs}

          describe '.update_attributes' do

            it "should update_attributes" do
              update
              name_attribute.should == new_name
            end

            it "should save the instance" do
              instance.should_receive(:save)
              update
            end

          end

          describe '.update_attributes!' do

            it "should update_attributes!" do
              update!
              name_attribute.should == new_name
            end

            it "should save the instance" do
              instance.should_receive(:save!)
              update!
            end

          end
        end

        describe "with invalid values" do
          let(:update) {subject.update_attributes new_invalid_attrs}
          let(:update!) {subject.update_attributes! new_invalid_attrs}

          describe '.update_attributes' do
            it "should not throw exception" do
              lambda { update }.should_not raise_error
            end
          end

          describe '.update_attributes!' do
            it "should throw exception" do
              lambda { update! }.should_not raise_error
            end
          end
        end



      end

      describe 'when saving' do

        before do
          subject.name = instance_name
        end

        describe 'new one' do
          let(:saving) { instance.save }

          before do
            resource.
                should_receive(:create).
                any_number_of_times.
                with({ 'a_child_klass' => { 'name' => subject.name, :id_name => subject.id_name } },
                     klass.header).
                and_return [{ 'a_child_klass' => { 'name' => subject.name, 'id' => instance_id } }, mock('response')]
          end

          describe '#save' do
            it { saving.should be_true }
          end

          it do
            should_not be_persisted
            saving
            should be_persisted
          end
          its(:id) { saving; should == instance_id }
        end

        describe 'already persisted' do
          subject { persisted_instance }
          let(:saving) { persisted_instance.save }

          before do
            resource.
                should_receive(:update).
                any_number_of_times.
                with({ 'id' => instance_id, 'a_child_klass' => { 'name' => subject.name, :id_name => subject.id_name } },
                     klass.header).
                and_return [{ 'a_child_klass' => { 'name' => subject.name, 'id' => instance_id } }, mock('response')]
          end

          describe '#save' do
            it { saving.should be_true }
          end

          it do
            should be_persisted
            saving
            should be_persisted
          end
          its(:id) { saving; should == instance_id }
          its(:name) { saving; should == 'Invisible man' }

          describe '#destroy' do
            let(:destroying) { persisted_instance.destroy }
            before do
              resource.
                  should_receive(:destroy).
                  with({ 'id' => instance_id }, klass.header).
                  and_return [{ 'a_child_klass' => { 'name' => subject.name, 'id' => instance_id } }, mock('response')]
            end

            it { destroying.should == true }
          end
        end
      end


    end


  end

end

