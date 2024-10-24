require 'katello_test_helper'

module Katello
  class KatelloLabelFormatValidatorMockModel < Hash
    def initialize
      super
      self[:name] = []
    end

    def add(attribute, message)
      self[attribute] << message
    end
  end
  class KatelloLabelFormatValidatorTest < ActiveSupport::TestCase
    def setup
      @validator = Validators::KatelloLabelFormatValidator.new(:attributes => [:name])
      @model = OpenStruct.new(:errors => KatelloLabelFormatValidatorMockModel.new)
    end

    def test_validate_each
      @validator.validate_each(@model, :name, "Test2Name_underline-dash")

      assert_empty @model.errors[:name]
    end

    test "fails with HTML tag" do
      @validator.validate_each(@model, :name, '<a href="">Test Name</a>')

      refute_empty @model.errors[:name]
    end

    test "fails with more than 128 characters" do
      cs = [*'0'..'9', *'a'..'z', *'A'..'Z']
      random_string = 129.times.map { cs.sample }.join
      @validator.validate_each(@model, :name, random_string)

      refute_empty @model.errors[:name]
    end

    test "fails if blank" do
      @validator.validate_each(@model, :name, '')

      refute_empty @model.errors[:name]
    end

    test "fails with trailing white space" do
      @validator.validate_each(@model, :name, "Trailing Whitespace   ")

      refute_empty @model.errors[:name]
    end
  end
end
