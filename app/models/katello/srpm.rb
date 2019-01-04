module Katello
  class Srpm < Katello::Model
    include Concerns::PulpDatabaseUnit

    CONTENT_TYPE = 'srpm'.freeze

    has_many :repository_srpms, :class_name => "Katello::RepositorySrpm", :dependent => :destroy, :inverse_of => :srpm
    has_many :repositories, :through => :repository_srpms, :class_name => "Katello::Repository"

    before_save lambda { |rpm| rpm.summary = rpm.summary.truncate(255) unless rpm.summary.blank? }

    def self.repository_association_class
      RepositorySrpm
    end

    def self.total_for_repositories(repos)
      self.in_repositories(repos).count
    end

    def nvrea
      Util::Package.build_nvrea(self.attributes.with_indifferent_access, false)
    end

    def build_nvra
      Util::Package.build_nvra(self.attributes.with_indifferent_access)
    end
  end
end
