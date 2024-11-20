require 'katello_test_helper'

module Katello
  class GpgKeyContentValidatorTest < ActiveSupport::TestCase
    def setup
      @validator = Validators::GpgKeyContentValidator.new(:attributes => [:content])
      @gpg_key = ContentCredential.find(katello_gpg_keys(:fedora_gpg_key).id)
      SETTINGS[:katello][:gpg_strict_validation] = true
    end

    def teardown
      SETTINGS[:katello][:gpg_strict_validation] = false
    end

    test "test gpg_key file validation" do
      response = @validator.validate_each(@gpg_key, :content, @gpg_key.content)
      assert_equal 'must contain valid Public GPG Key', response.message
    end
  end
end
