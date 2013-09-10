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

describe String do
  it "should translate true strings" do
    %w(True T t true Yes yes Y y 1).all? { |v| v.to_bool.should be_true }
  end

  it "should translate false strings" do
    %w(False F f false No no n N 0).all? { |v| v.to_bool.should be_false }
  end

  it "should rase an exception for unknown strings" do
    lambda {"JarjarBinks".to_bool()}.should raise_exception
  end
end