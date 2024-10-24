# encoding: utf-8

require 'katello_test_helper'

module Katello
  class KatelloNameFormatValidatorMockModel < Hash
    def initialize
      super
      self[:name] = []
    end

    def add(attribute, message)
      self[attribute] << message
    end
  end
  class KatelloNameFormatValidatorTest < ActiveSupport::TestCase
    def setup
      @validator = Validators::KatelloNameFormatValidator.new(:attributes => [:name])
      @model = OpenStruct.new(:errors => KatelloNameFormatValidatorMockModel.new)
    end

    def test_validate_each
      @validator.validate_each(@model, :name, "Test2 Name_underline-dash í18n_chäřs")

      assert_empty @model.errors[:name]
    end

    test "succeeds with HTML tag" do
      @validator.validate_each(@model, :name, '<a href="">Test Name</a>')

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
end
