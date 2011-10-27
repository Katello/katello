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

describe Glue::Pulp::Distribution do

  before (:each) do
    disable_distribution_orchestration
  end
  
  context "Find distribution" do
    it "should call pulp find distribution api" do
      
      Pulp::Distribution.should_receive(:find).once.with('1')
      Glue::Pulp::Distribution.find('1')
    end
    
    it "should create new Distribution" do

      Glue::Pulp::Distribution.should_receive(:new)
      Glue::Pulp::Distribution.find('1')
    end
  end
  
end


def disable_distribution_orchestration
  Pulp::Distribution.stub(:find).and_return({})
end
