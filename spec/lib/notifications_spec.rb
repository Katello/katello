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


describe Notifications do

  before (:each) do
    @notice_string           = 'This is a single string notification.'
    @notice_string_array     = [@notice_string, @notice_string + '2', @notice_string + '3', @notice_string +'4']
    @notice_validation_error = ActiveRecord::RecordInvalid.new(User.create())
    @notice_standard_error   = StandardError.new()
    @notice_standard_error.set_backtrace caller
  end

  let(:controller) { mock 'controller', :requested_action => 'a_controller___an_action', :flash => { },
                          :notices_url                    => 'http://localhost:3000/katello/notices' }
  let(:notifier) { Notifications::Notifier.new(controller) }

  describe 'create a notification that is asynchronous' do
    describe 'with the notice as a string' do
      it 'should generate a notice', :katello => true do #TODO headpin
        notifier.message @notice_string
        Notice.count.should == 1
      end
    end

    describe 'with the notice as an array' do
      it 'should generate a notice', :katello => true do #TODO headpin
        notifier.message @notice_string_array
        Notice.count.should == 1
      end
    end

    describe 'with the notice as an ActiveRecord::RecordInvalid exception' do
      it 'should generate a notice', :katello => true do #TODO headpin
        notifier.exception @notice_validation_error, :asynchronous => true, :persist => true
        Notice.count.should == 1
      end
    end

    describe 'with the notice as a RuntimeError exception' do
      it 'should generate a notice', :katello => true do #TODO headpin
        notifier.exception @notice_standard_error, :asynchronous => true
        Notice.count.should == 1
      end
    end
  end

  describe 'create a notification that is synchronous' do
    before (:each) do
      User.stub!(:current).and_return(@user)
    end

    describe 'with the notice as a string' do
      it 'should generate a notice', :katello => true do #TODO headpin
        notifier.success(@notice_string)
        Notice.count.should == 1
      end
    end

    describe 'with the notice as an array' do
      it 'should generate a notice', :katello => true do #TODO headpin
        notifier.success(@notice_string_array)
        Notice.count.should == 1
      end
    end

    describe 'with the notice as an ActiveRecord::RecordInvalid exception' do
      it 'should generate a notice', :katello => true do #TODO headpin
        notifier.exception(@notice_validation_error, :persist => true)
        Notice.count.should == 1
      end
    end

    describe 'with the notice as a RuntimeError exception' do
      it 'should generate a notice', :katello => true do #TODO headpin
        notifier.exception(@notice_standard_error)
        Notice.count.should == 1
      end
    end

    describe 'and does not persist' do
      describe 'with the notice as a string' do
        it 'should generate a notice', :katello => true do #TODO headpin
          notifier.success(@notice_string, { :persist => false })
          Notice.count.should == 0
        end
      end
    end
  end

  describe 'create an errors notification' do
    before (:each) do
      User.stub!(:current).and_return(@user)
    end

    it 'should have the level set to :error', :katello => true do #TODO headpin
      notifier.error(@notice_string)
      Notice.count.should == 1
      Notice.first.level.should == "error"

    end
  end

end
