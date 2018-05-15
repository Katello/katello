require 'katello_test_helper'

module Katello
  class GpgKeyTest < ActiveSupport::TestCase
    should allow_values(*valid_name_list).for(:name)
    should_not allow_values(*invalid_name_list).for(:name)
    should_not allow_values('', ' ', "\t", *RFauxFactory.gen_strings(247).values).for(:content)
  end
end
