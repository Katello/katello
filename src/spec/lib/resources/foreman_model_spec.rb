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

require 'spec_helper'

describe Resources::ForemanModel do

  let(:resource) { mock('resource') }
  let(:klass) { Resources::ForemanModel }
  let(:instance) { klass.new }

  before { klass.resource = resource }
  after { klass.resource = nil }

  subject { klass }

  it "should have attribute :id" do
    expect(subject.attributes).to match_array([:id])
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
      before { subject.send :persist! }

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

        self.resource_name       = 'a_child_klass'
        self.current_user_getter = lambda { that.mock('user', :username => 'username') }

        attributes :name
        validates :name, :presence => true
      end
    end

    it "should have attributes :id, :name" do
      expect(subject.attributes).to match_array([:id, :name])
    end

    describe '.find!' do
      before do
        resource.
            should_receive(:show).
            with(3, nil, klass.foreman_header).
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
            with(params, klass.foreman_header).
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
        before { subject.attributes = { :id => 3, :name => 'JonDoe' } }
        it { should be_valid }

        it "should serialize" do
          subject.as_json.should == { 'a_child_klass' => { 'name' => subject.name, :id_name => subject.id_name } }
        end
      end

      describe 'when saving' do
        before do
          subject.name = 'JonDoe'
        end

        let(:saving) { instance.save }

        describe 'new one' do
          before do
            resource.
                should_receive(:create).
                any_number_of_times.
                with({ 'a_child_klass' => { 'name' => subject.name, :id_name => subject.id_name } },
                     klass.foreman_header).
                and_return [{ 'a_child_klass' => { 'name' => subject.name, 'id' => 3 } }, mock('response')]
          end

          describe '#save' do
            it { saving.should be_true }
          end

          it do
            should_not be_persisted
            saving
            should be_persisted
          end
          its(:id) { saving; should == 3 }
        end

        describe 'already persisted' do
          before do
            subject.id   = 3
            subject.name = 'Invisible man'
            subject.send :persist!
            resource.
                should_receive(:update).
                any_number_of_times.
                with(3, { 'a_child_klass' => { 'name' => subject.name, :id_name => subject.id_name } },
                     klass.foreman_header).
                and_return [{ 'a_child_klass' => { 'name' => subject.name, 'id' => 3 } }, mock('response')]
          end

          describe '#save' do
            it { saving.should be_true }
          end

          it do
            should be_persisted
            saving
            should be_persisted
          end
          its(:id) { saving; should == 3 }
          its(:name) { saving; should == 'Invisible man' }

          describe '#destroy' do
            let(:destroying) { instance.destroy }
            before do
              resource.
                  should_receive(:destroy).
                  with(3, nil, klass.foreman_header).
                  and_return [{ 'a_child_klass' => { 'name' => subject.name, 'id' => 3 } }, mock('response')]
            end

            it { destroying.should == true }
          end
        end
      end


    end


  end

end

