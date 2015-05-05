module Katello
  class CpConsumerUser < ::User
    validates_lengths_from_database
    attr_accessor :uuid

    def cp_oauth_header
      { 'cp-consumer' => self.uuid }
    end
  end
end
