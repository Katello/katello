module Katello
  class ContentIndex < Katello::Model
    # Repositories holding the same Pulp version share one index, which is never
    # mutated while another repository references it.
    has_many :content_index_rpms, :dependent => :delete_all, :inverse_of => :content_index
    has_many :content_index_errata, :dependent => :delete_all, :inverse_of => :content_index
    has_many :content_index_srpms, :dependent => :delete_all, :inverse_of => :content_index
    has_many :content_index_module_streams, :dependent => :delete_all, :inverse_of => :content_index
    has_many :content_index_debs, :dependent => :delete_all, :inverse_of => :content_index
    has_many :content_index_file_units, :dependent => :delete_all, :inverse_of => :content_index
    has_many :content_index_package_groups, :dependent => :delete_all, :inverse_of => :content_index
    has_many :content_index_ansible_collections, :dependent => :delete_all, :inverse_of => :content_index
    has_many :content_index_generic_content_units, :dependent => :delete_all, :inverse_of => :content_index

    has_many :repositories, :class_name => 'Katello::Repository', :inverse_of => :content_index, :dependent => :nullify

    validates :version_href, :presence => true, :uniqueness => true

    def self.for_version(version_href)
      find_or_create_by!(:version_href => version_href)
    rescue ActiveRecord::RecordNotUnique
      find_by!(:version_href => version_href)
    end

    # Indexes the set uses plus the repositories that have none yet; a pointer
    # naming another version counts as none.
    def self.scope_for_repositories(repositories)
      rows = ::Katello::Repository.where(:id => repositories).pluck(:id, :content_index_id, :version_href)
      index_ids = rows.map { |row| row[1] }.compact.uniq
      return [[], rows.map(&:first)] if index_ids.empty?

      index_versions = where(:id => index_ids).pluck(:id, :version_href).to_h
      indexed, unindexed = rows.partition { |row| row[1].present? && index_versions[row[1]] == row[2] }
      [indexed.map { |row| row[1] }.uniq, unindexed.map(&:first)]
    end

    # Copy-on-write: nobody but this repository may depend on the index rows.
    def private_to?(repository)
      repositories.where.not(:id => repository).none?
    end

    # NOT IN over a subquery with NULLs matches nothing, so ask with NOT EXISTS.
    def self.orphaned
      where.missing(:repositories)
    end
  end
end
