module Katello
  class Erratum < Katello::Model
    include Glue::Pulp::PulpContentUnit

    SECURITY = "security"
    BUGZILLA = "bugfix"
    ENHANCEMENT = "enhancement"

    TYPES = [SECURITY, BUGZILLA, ENHANCEMENT]
    CONTENT_TYPE = "erratum"

    has_many :systems_applicable, :through => :system_errata, :class_name => "Katello::System", :source => :system
    has_many :system_errata, :class_name => "Katello::SystemErratum", :dependent => :destroy, :inverse_of => :erratum

    has_many :repositories, :through => :repository_errata, :class_name => "Katello::Repository"
    has_many :repository_errata, :class_name => "Katello::RepositoryErratum", :dependent => :destroy, :inverse_of => :erratum

    has_many :bugzillas, :class_name => "Katello::ErratumBugzilla", :dependent => :destroy, :inverse_of => :erratum
    has_many :cves, :class_name => "Katello::ErratumCve", :dependent => :destroy, :inverse_of => :erratum
    has_many :packages, :class_name => "Katello::ErratumPackage", :dependent => :destroy, :inverse_of => :erratum

    scoped_search :on => :errata_id, :rename => :id, :complete_value => true
    scoped_search :on => :title, :only_explicit => true
    scoped_search :on => :severity, :complete_value => true
    scoped_search :on => :errata_type, :rename => :type, :complete_value => true
    scoped_search :on => :issued, :complete_value => true
    scoped_search :on => :updated, :complete_value => true
    scoped_search :in => :cves, :on => :cve_id, :rename => :cve
    scoped_search :in => :bugzillas, :on => :bug_id, :rename => :bug
    scoped_search :in => :packages, :on => :nvrea, :rename => :package, :complete_value => true
    scoped_search :in => :packages, :on => :name, :rename => :package_name, :complete_value => true

    before_save lambda { |erratum| erratum.title = erratum.title.truncate(255) unless erratum.title.blank? }

    def self.of_type(type)
      where(:errata_type => type)
    end

    scope :security, -> { of_type(Erratum::SECURITY) }
    scope :bugfix, -> { of_type(Erratum::BUGZILLA) }
    scope :enhancement, -> { of_type(Erratum::ENHANCEMENT) }

    def self.repository_association_class
      RepositoryErratum
    end

    def self.applicable_to_systems(systems)
      self.joins(:system_errata).where("#{SystemErratum.table_name}.system_id" => systems).uniq
    end

    def <=>(other)
      return self.errata_id <=> other.errata_id
    end

    def systems_available
      self.systems_applicable.joins("INNER JOIN #{Katello::RepositoryErratum.table_name} on \
        #{Katello::RepositoryErratum.table_name}.erratum_id = #{self.id}").joins(:system_repositories).
        where("#{Katello::SystemRepository.table_name}.repository_id = #{Katello::RepositoryErratum.table_name}.repository_id").uniq
    end

    def systems_unavailable
      self.systems_applicable.where("#{Katello::System.table_name}.id not in (#{self.systems_available.select("#{Katello::System.table_name}.id").to_sql})")
    end

    def self.installable_for_systems(systems = nil)
      query = Katello::Erratum.joins(:system_errata).joins(:repository_errata).joins("INNER JOIN #{Katello::SystemRepository.table_name} on \
        #{Katello::SystemRepository.table_name}.system_id = #{Katello::SystemErratum.table_name}.system_id").
        joins("INNER JOIN #{Katello::RepositoryErratum.table_name} AS system_repo_errata ON \
          system_repo_errata.erratum_id = #{Katello::Erratum.table_name}.id").
        where("#{Katello::SystemRepository.table_name}.repository_id = system_repo_errata.repository_id")
      query.where("#{Katello::SystemRepository.table_name}.system_id" => [systems.map(&:id)]) if systems
      query
    end

    def update_from_json(json)
      keys = %w(title id severity issued type description reboot_suggested solution updated summary)
      custom_json = json.clone.delete_if { |key, _value| !keys.include?(key) }

      if self.updated.blank? || (custom_json['updated'].to_datetime != self.updated.to_datetime)
        custom_json['errata_id'] = custom_json.delete('id')
        custom_json['errata_type'] = custom_json.delete('type')

        self.update_attributes!(custom_json)

        unless json['references'].blank?
          update_bugzillas(json['references'].select { |r| r['type'] == 'bugzilla' })
          update_cves(json['references'].select { |r| r['type'] == 'cve' })
        end
      end
      update_packages(json['pkglist']) unless json['pkglist'].blank?
    end

    def self.list_filenames_by_clauses(clauses)
      errata = Katello.pulp_server.extensions.errata.search(Katello::Erratum::CONTENT_TYPE, :filters => clauses)
      Katello::ErratumPackage.joins(:erratum).where("#{Erratum.table_name}.uuid" => errata.map { |e| e['_id'] }).pluck(:filename)
    end

    def self.unit_handler
      Katello.pulp_server.extensions.errata
    end

    private

    def run_until(needed_function, action_function)
      needed = needed_function.call
      retries = needed.length
      until needed.empty? || retries == 0
        begin
          action_function.call(needed)
        rescue ActiveRecord::RecordNotUnique
          self.reload
        end
        needed = needed_function.call
        retries -= 1
      end
      fail _('Failed indexing errata, maximum retries encountered') if retries == 0 && needed.any?
    end

    def update_bugzillas(json)
      needed_function = lambda do
        existing_names = bugzillas.pluck(:bug_id)
        json.select { |bz| !existing_names.include?(bz['id']) }
      end
      action_function = lambda do |needed|
        bugzillas.create!(needed.map { |bug| {:bug_id => bug['id'], :href => bug['href']} })
      end
      run_until(needed_function, action_function)
    end

    def update_cves(json)
      needed_function = lambda do
        existing_names = cves.pluck(:cve_id)
        json.select { |cve| !existing_names.include?(cve['id']) }
      end
      action_function = lambda do |needed|
        cves.create!(needed.map { |cve| {:cve_id => cve['id'], :href => cve['href']} })
      end
      run_until(needed_function, action_function)
    end

    def update_packages(json)
      needed_function = lambda do
        package_hashes = json.map { |list| list['packages'] }.flatten
        package_attributes = package_hashes.map do |hash|
          nvrea = "#{hash['name']}-#{hash['version']}-#{hash['release']}.#{hash['arch']}"
          {'name' => hash['name'], 'nvrea' => nvrea, 'filename' => hash['filename']}
        end
        existing_nvreas = self.packages.pluck(:nvrea)
        package_attributes.delete_if { |pkg| existing_nvreas.include?(pkg['nvrea']) }
        package_attributes.uniq { |pkg| pkg['nvrea'] }
      end
      action_function = lambda do |needed|
        self.packages.create!(needed)
      end
      run_until(needed_function, action_function)
    end
  end
end
