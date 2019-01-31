module Katello
  class Distribution < Katello::Model
    include Concerns::PulpDatabaseUnit
    CONTENT_TYPE = "distribution".freeze
  end
end
