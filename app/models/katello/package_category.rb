module Katello
  class PackageCategory < Katello::Model
    include Concerns::PulpDatabaseUnit
    CONTENT_TYPE = "package_category".freeze
  end
end
