# encoding: utf-8
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

require 'minitest_helper'

class KatelloNameFormatValidatorTest < MiniTest::Rails::ActiveSupport::TestCase

  def setup
    @validator = Validators::KatelloNameFormatValidator.new({:attributes => [:name]})
    @model = OpenStruct.new(:errors => {:name => []})
  end

  def test_validate_each
    @validator.validate_each(@model, :name, "Test2 Name_underline-dash í18n_chäřs")

    assert_empty @model.errors[:name]
  end

  test "succeeds with HTML tag" do
    @validator.validate_each(@model, :name, '<a href="">Test Name</a>')

    assert_empty @model.errors[:name]
  end

  test "fails with more than 255 characters" do
    cs = [*'0'..'9', *'a'..'z', *'A'..'Z']
    random_string = 256.times.map { cs.sample }.join
    @validator.validate_each(@model, :name, random_string)

    refute_empty @model.errors[:name]
  end

  test "succeeds with 255 characters" do
    cs = [*'0'..'9', *'a'..'z', *'A'..'Z']
    random_string = 255.times.map { cs.sample }.join
    @validator.validate_each(@model, :name, random_string)

    assert_empty @model.errors[:name]
  end

  test "succeeds with special characters" do
    @validator.validate_each(@model, :name, '@!#$%^&*()')

    assert_empty @model.errors[:name]
  end

  test "succeeds with special characters and html tag" do
    @validator.validate_each(@model, :name, 'bar_+{}|"?<blink>hi</blink>')

    assert_empty @model.errors[:name]
  end

  test "fails if blank" do
    @validator.validate_each(@model, :name, '')

    refute_empty @model.errors[:name]
  end

  test "fails with trailing white space" do
    @validator.validate_each(@model, :name, "Trailing Whitespace   ")

    refute_empty @model.errors[:name]
  end

  test "succeeds with dot" do
    @validator.validate_each(@model, :name, "Weightlifting Dept.")

    assert_empty @model.errors[:name]
  end

end
