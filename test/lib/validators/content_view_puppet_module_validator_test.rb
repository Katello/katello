# encoding: utf-8

require 'katello_test_helper'

module Katello
  class ContentViewPuppetModuleValidatorTest < ActiveSupport::TestCase
    def setup
      @rhel_repository = katello_repositories(:rhel_6_x86_64)
      @repository = katello_repositories(:p_forge)
      @base_record = { errors: { base: [] }, content_view: OpenStruct.new(puppet_repos: [@repository], organization: @repository.organization) }
      @validator = Validators::ContentViewPuppetModuleValidator.new(attributes: [:name])
    end

    test "passes if name and author match a puppet module" do
      pm = katello_puppet_modules(:abrt)
      @model = OpenStruct.new(@base_record.merge(name: pm.name, author: pm.author))
      @validator.validate(@model)
      assert_empty @model.errors[:base]
    end

    test "fails if only name provided" do
      @model = OpenStruct.new(@base_record.merge(name: "abrt"))
      @validator.validate(@model)

      refute_empty @model.errors[:base]
    end

    test "fails if only author provided" do
      @model = OpenStruct.new(@base_record.merge(author: "johndoe"))
      @validator.validate(@model)

      refute_empty @model.errors[:base]
    end

    test "fails if name and author do not match a puppet module" do
      @model = OpenStruct.new(@base_record.merge(name: "abrt", author: "Nyota Uhura"))
      @validator.validate(@model)
      refute_empty @model.errors[:base]
    end

    test "fails if both name and uuid blank" do
      @model = OpenStruct.new(errors: {base: []})
      @validator.validate(@model)

      refute_empty @model.errors[:base]
    end

    test "passes if uuid matches a puppet module" do
      @model = OpenStruct.new(@base_record.merge(uuid: katello_puppet_modules(:abrt).uuid))
      @validator.validate(@model)

      assert_empty @model.errors[:base]
    end

    test "fails if uuid does not match a puppet module" do
      @model = OpenStruct.new(@base_record.merge(uuid: "3bd47a52-90ff-20630asddfat"))
      Katello::PuppetModule.stubs(:exists?).returns(false)
      @validator.validate(@model)

      refute_empty @model.errors[:base]
    end

    test "fails if puppet module does not belong to a repository in the content view organization" do
      @model = OpenStruct.new(@base_record.merge(
        uuid: katello_puppet_modules(:abrt).uuid, content_view: OpenStruct.new(
          organization: OpenStruct.new(name: :dev))))
      @validator.validate(@model)

      refute_empty @model.errors[:base]
    end

    test "passes if identical puppet modules belong to repositories of different organizations including the content view organization" do
      puppet_module = mock('Katello::PuppetModule')
      repo = mock('Katello::Repository')

      puppet_module.stubs(:repositories).returns([repo])
      Katello::PuppetModule.stubs(:where).returns([katello_puppet_modules(:abrt), puppet_module])
      repo.stubs(:organization).returns(:dev)

      @model = OpenStruct.new(@base_record.merge(
        name: "abrt", author: "johndoe",
        content_view: OpenStruct.new(organization: :dev)))
      @validator.validate(@model)

      assert_empty @model.errors[:base]
    end

    test "fails if identical puppet modules belong to repositories of different organizations excluding the content view organization" do
      puppet_module = mock('Katello::PuppetModule')
      repo = mock('Katello::Repository')

      puppet_module.stubs(:repositories).returns([repo])
      Katello::PuppetModule.stubs(:where).returns([katello_puppet_modules(:abrt), puppet_module])
      repo.stubs(:organization).returns(:dev)

      @model = OpenStruct.new(@base_record.merge(
        name: "abrt", author: "johndoe",
        content_view: OpenStruct.new(organization: OpenStruct.new(name: :not_dev))))
      @validator.validate(@model)

      refute_empty @model.errors[:base]
    end
  end
end
