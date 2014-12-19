#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

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

    scope :security, of_type(Erratum::SECURITY)
    scope :bugfix, of_type(Erratum::BUGZILLA)
    scope :enhancement, of_type(Erratum::ENHANCEMENT)

    def self.repository_association_class
      RepositoryErratum
    end

    def self.applicable_to_systems(systems)
      self.joins(:system_errata).where("#{SystemErratum.table_name}.system_id" => systems)
    end

    def systems_available
      self.systems_applicable.joins("INNER JOIN #{Katello::RepositoryErratum.table_name} on \
        #{Katello::RepositoryErratum.table_name}.erratum_id = #{self.id}").joins(:system_repositories).
        where("#{Katello::SystemRepository.table_name}.repository_id = #{Katello::RepositoryErratum.table_name}.repository_id")
    end

    def systems_unavailable
      self.systems_applicable.where("#{Katello::System.table_name}.id not in (#{self.systems_available.select("#{Katello::System.table_name}.id").to_sql})")
    end

    def self.available_for_systems(systems = nil)
      query = Katello::Erratum.joins(:system_errata).joins(:repository_errata).joins("INNER JOIN #{Katello::SystemRepository.table_name} on \
        #{Katello::SystemRepository.table_name}.system_id = #{Katello::SystemErratum.table_name}.system_id").
          where("#{Katello::SystemRepository.table_name}.repository_id = #{Katello::RepositoryErratum.table_name}.repository_id")
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

        update_packages(json['pkglist']) unless json['pkglist'].blank?
      end
    end

    def self.list_filenames_by_clauses(clauses)
      errata = Katello.pulp_server.extensions.errata.search(Katello::Erratum::CONTENT_TYPE, :filters => clauses)
      Katello::ErratumPackage.joins(:erratum).where("#{Erratum.table_name}.uuid" => errata.map { |e| e['_id'] }).pluck(:filename)
    end

    private

    def update_bugzillas(json)
      existing_names = self.bugzillas.pluck(:bug_id)
      needed = json.select { |bz| !existing_names.include?(bz['id']) }
      self.bugzillas.create!(needed.map { |bug| {:bug_id => bug['id'], :href => bug['href']} })
    end

    def update_cves(json)
      existing_names = self.cves.pluck(:cve_id)
      needed = json.select { |cve| !existing_names.include?(cve['id']) }
      self.cves.create!(needed.map { |cve| {:cve_id => cve['id'], :href => cve['href']} })
    end

    def update_packages(json)
      package_hashes = json.map { |list| list['packages'] }.flatten
      package_attributes = package_hashes.map do |hash|
        nvrea = "#{hash['name']}-#{hash['version']}-#{hash['release']}.#{hash['arch']}"
        {'name' => hash['name'], 'nvrea' => nvrea, 'filename' => hash['filename']}
      end
      existing_nvreas = self.packages.pluck(:nvrea)
      package_attributes.delete_if { |pkg| existing_nvreas.include?(pkg['nvrea']) }

      self.packages.create!(package_attributes)
    end
  end
end
