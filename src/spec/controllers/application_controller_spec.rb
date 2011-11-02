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

describe ApplicationController do  
  include LoginHelperMethods
  include LocaleHelperMethods
  
  before (:each) do
    set_default_locale
    login_user :mock => false
    
    @notice_string = 'This is a single string notification.'
    @notice_string_array = [@notice_string, @notice_string + '2', @notice_string + '3', @notice_string +'4']
    @notice_validation_error = ActiveRecord::RecordInvalid.new(User.create())
    @notice_runtime_error = RuntimeError.new()
  end
  
  describe 'create a notification that is asynchronous' do
    describe 'with the notice as a string' do
      it 'should generate a notice' do
        controller.notice(@notice_string, { :synchronous_request => false})
        Notice.count.should == 1
      end
    end
    
    describe 'with the notice as an array' do
      it 'should generate a notice' do
        controller.notice(@notice_string_array, { :synchronous_request => false})
        Notice.count.should == 1
      end
    end
    
    describe 'with the notice as an ActiveRecord::RecordInvalid exception' do
      it 'should generate a notice' do
        controller.notice(@notice_validation_error, { :synchronous_request => false})
        Notice.count.should == 1
      end
    end
    
    describe 'with the notice as a RuntimeError exception' do
      it 'should generate a notice' do
        controller.notice(@notice_runtime_error, { :synchronous_request => false})
        Notice.count.should == 1
      end
    end
  end

  describe 'create a notification that is synchronous' do
    describe 'with the notice as a string' do
      it 'should generate a notice' do
        controller.notice(@notice_string)
        Notice.count.should == 1
      end
    end
    
    describe 'with the notice as an array' do
      it 'should generate a notice' do
        controller.notice(@notice_string_array)
        Notice.count.should == 1
      end
    end
    
    describe 'with the notice as an ActiveRecord::RecordInvalid exception' do
      it 'should generate a notice' do
        controller.notice(@notice_validation_error)
        Notice.count.should == 1
      end
    end
    
    describe 'with the notice as a RuntimeError exception' do
      it 'should generate a notice' do
        controller.notice(@notice_runtime_error)
        Notice.count.should == 1
      end
    end
    
    describe 'and does not persist' do
      describe 'with the notice as a string' do
        it 'should generate a notice' do
          controller.notice(@notice_string, { :persist => false})
          Notice.count.should == 0
        end
      end
      
      describe 'with the notice as an array' do
        it 'should generate a notice' do
          controller.notice(@notice_string_array, { :persist => false})
          Notice.count.should == 0
        end
      end
      
      describe 'with the notice as an ActiveRecord::RecordInvalid exception' do
        it 'should generate a notice' do
          controller.notice(@notice_validation_error, { :persist => false})
          Notice.count.should == 0
        end
      end
      
      describe 'with the notice as a RuntimeError exception' do
        it 'should generate a notice' do
          controller.notice(@notice_runtime_error, { :persist => false})
          Notice.count.should == 0
        end
      end
    end
  end
  
  describe 'create an errors notification' do
    it 'should have the level set to :error' do
      controller.errors(@notice_string)
      Notice.count.should == 1
      notice = Notice.search_for(@notice_string)[0]
      notice.level.should == "error"
    end
  end
  
end