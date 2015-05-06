require 'katello_test_helper'

module Katello
  describe Mapping do
    let :map do
      {
        "imagefactory_naming" =>
          {
            "Red Hat Enterprise Linux 6" => ["RHEL-6", 0],
            "Red Hat Enterprise Linux* 6.0" => ["RHEL-6", 0],
            "Red Hat Enterprise Linux* 5.5" => ["RHEL-5", "U5"],
            "Fedora 15" => %w(Fedora 15)
          }
      }
    end

    before :each do
      Mapping.stubs(:configuration).returns(map)
    end

    it "should handle nils" do
      Mapping::ImageFactoryNaming.translate.must_equal ["", ""]
    end

    it "should handle empty values" do
      Mapping::ImageFactoryNaming.translate("", "").must_equal ["", ""]
    end

    it "should handle identity" do
      Mapping::ImageFactoryNaming.translate("Fedora", "15").must_equal %w(Fedora 15)
    end

    it "should ba able to handle wild chars" do
      Mapping::ImageFactoryNaming.translate("Red Hat Enterprise Linux Server", "5.5").must_equal ["RHEL-5", "U5"]
    end
  end
end
