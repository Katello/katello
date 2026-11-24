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
    rescue ActiveRecord::RecordInvalid => e
      # The uniqueness validator raises this when the competing row was already
      # visible; any other validation failure is real.
      raise unless e.record.is_a?(ContentIndex) && e.record.errors.of_kind?(:version_href, :taken)

      find_by!(:version_href => version_href)
    end

    # Relations, not ids: the pointer and the version are compared when the query
    # runs, so a repository that advances in between counts as unindexed.
    def self.indexed_repositories(repositories)
      ::Katello::Repository.where(:id => repositories).
        joins(:content_index).
        where("#{table_name}.version_href = #{::Katello::Repository.table_name}.version_href")
    end

    def self.unindexed_repositories(repositories)
      ::Katello::Repository.where(:id => repositories).
        where.not(:id => indexed_repositories(repositories).select(:id))
    end

    # The same split for callers that need the values now; one statement, so a
    # repository cannot move between the two sets while they are read.
    def self.scope_for_repositories(repositories)
      rows = ::Katello::Repository.where(:id => repositories).
        joins("LEFT JOIN #{table_name} ON #{table_name}.id = #{::Katello::Repository.table_name}.content_index_id " \
              "AND #{table_name}.version_href = #{::Katello::Repository.table_name}.version_href").
        pluck("#{::Katello::Repository.table_name}.id", "#{table_name}.id")
      indexed, unindexed = rows.partition { |_repository_id, index_id| index_id.present? }
      [indexed.map(&:last).uniq, unindexed.map(&:first)]
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
