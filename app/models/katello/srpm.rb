module Katello
  class Srpm < Katello::Model
    include Concerns::PulpDatabaseUnit

    CONTENT_TYPE = Pulp::Rpm::CONTENT_TYPE

    has_many :repositories, :through => :repository_srpms, :class_name => "Katello::Repository"
    has_many :repository_srpms, :class_name => "Katello::RepositorySrpm", :dependent => :destroy, :inverse_of => :srpm

    before_save lambda { |rpm| rpm.summary = rpm.summary.truncate(255) unless rpm.summary.blank? }

    def self.repository_association_class
      RepositorySrpm
    end

    def update_from_json(json)
      keys = Pulp::Srpm::PULP_INDEXED_FIELDS - ['_id']
      custom_json = json.slice(*keys)
      if custom_json.any? { |name, value| self.send(name) != value }
        custom_json[:release_sortable] = Util::Package.sortable_version(custom_json[:release])
        custom_json[:version_sortable] = Util::Package.sortable_version(custom_json[:version])
        self.assign_attributes(custom_json)
        self.nvra = self.build_nvra
        self.save!
      end
    end

    def self.total_for_repositories(repos)
      self.in_repositories(repos).uniq.count
    end

    def nvrea
      Util::Package.build_nvrea(self.attributes.with_indifferent_access, false)
    end

    def build_nvra
      Util::Package.build_nvra(self.attributes.with_indifferent_access)
    end
  end
end
