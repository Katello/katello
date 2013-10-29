#
# Copyright 2013 Red Hat, Inc.
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
module Glue::ElasticSearch::Repository

  # TODO: break this up into modules
  # rubocop:disable MethodLength
  def self.included(base)
    base.send :include, Ext::IndexedModel

    base.class_eval do
      index_options :extended_json => :extended_index_attrs,
                    :json => {:except => [:pulp_repo_facts, :feed_cert]}

      mapping do
        indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :name_sort, :type => 'string', :index => :not_analyzed
        indexes :labels, :type => 'string', :index => :not_analyzed
      end

      after_save :update_related_index
      before_destroy :clear_content_indices
    end

    def extended_index_attrs
      {:environment => self.environment.name, :environment_id => self.environment.id, :clone_ids => self.clones.pluck(:pulp_id),
       :product => self.product.name, :product_id => self.product.id,
       :default_content_view => self.content_view_version.has_default_content_view?,
       :name_sort => self.name }
    end

    def update_related_index
      self.product.provider.update_index if self.product.provider.respond_to? :update_index
    end

    def index_packages
      Tire.index Katello::Package.index do
        create :settings => Katello::Package.index_settings, :mappings => Katello::Package.index_mapping
      end
      pkgs = self.packages.collect{|pkg| pkg.as_json.merge(pkg.index_options)}
      pkgs.each_slice(Katello.config.pulp.bulk_load_size) do |sublist|
        Tire.index Katello::Package.index do
          import sublist
        end if !sublist.empty?
      end
    end

    def update_packages_index
      # for each of the packages in the repo, unassociate the repo from the package
      pkgs = self.packages.collect{|pkg| pkg.as_json.merge(pkg.index_options)}
      pulp_id = self.pulp_id

      unless pkgs.empty?
        Tire.index Katello::Package.index do
          create :settings => Katello::Package.index_settings, :mappings => Katello::Package.index_mapping
        end unless Tire.index(Katello::Package.index).exists?

        Tire.index Katello::Package.index do
          import pkgs do |documents|
            documents.each do |document|
              if !document["repoids"].nil? && document["repoids"].length > 1
                # if there is more than 1 repo associated w/ the pkg, remove this repo
                document["repoids"].delete(pulp_id)
              end
            end
          end
        end
      end

      # now, for any package that only had this repo asscociated with it, remove the package from the index
      repoids = "repoids:#{pulp_id}"
      Tire::Configuration.client.delete "#{Tire::Configuration.url}/katello_package/_query?q=#{repoids}"
      Tire.index('katello_package').refresh
    end

    def index_errata
      errata = self.errata.collect{|err| err.as_json.merge(err.index_options)}
      unless errata.empty?
        Tire.index Errata.index do
          create :settings => Errata.index_settings, :mappings => Errata.index_mapping
        end unless Tire.index(Errata.index).exists?

        Tire.index Errata.index do
          import errata
        end
      end
    end

    def update_errata_index
      # for each of the errata in the repo, unassociate the repo from the errata
      errata = self.errata.collect{|err| err.as_json.merge(err.index_options)}
      pulp_id = self.pulp_id

      unless errata.empty?
        Tire.index Errata.index do
          create :settings => Errata.index_settings, :mappings => Errata.index_mapping
        end unless Tire.index(Errata.index).exists?

        Tire.index Errata.index do
          import errata do |documents|
            documents.each do |document|
              if !document["repoids"].nil? && document["repoids"].length > 1
                # if there is more than 1 repo associated w/ the errata, remove this repo
                document["repoids"].delete(pulp_id)
              end
            end
          end
        end
      end

      # now, for any errata that only had this repo asscociated with it, remove the errata from the index
      repoids = "repoids:#{pulp_id}"
      Tire::Configuration.client.delete "#{Tire::Configuration.url}/katello_errata/_query?q=#{repoids}"
      Tire.index('katello_errata').refresh
    end

    def index_package_groups
      package_groups_map = self.package_groups.collect{|pg| pg.as_json.merge(pg.index_options)}

      unless package_groups_map.empty?
        Tire.index Katello::PackageGroup.index do
          create :settings => Katello::PackageGroup.index_settings, :mappings => Katello::PackageGroup.index_mapping
        end unless Tire.index(Katello::PackageGroup.index).exists?

        Tire.index Katello::PackageGroup.index do
          import package_groups_map
        end
      end
    end

    def update_package_group_index
      # for each of the package_groups in the repo, unassociate the repo from the package_group
      pulp_id = self.pulp_id

      # now, for any package group that only had this repo asscociated with it,
      # remove the package group from the index
      repoid = "repo_id:#{pulp_id}"
      Tire::Configuration.client.delete "#{Tire::Configuration.url}/katello_package_group/_query?q=#{repoid}"
      Tire.index('katello_package_group').refresh
    end

    def index_puppet_modules
      Tire.index Katello::PuppetModule.index do
        create :settings => Katello::PuppetModule.index_settings, :mappings => Katello::PuppetModule.index_mapping
      end
      puppet_modules = self.puppet_modules.collect{|puppet_module| puppet_module.as_json.merge(puppet_module.index_options)}
      puppet_modules.each_slice(Katello.config.pulp.bulk_load_size) do |sublist|
        Tire.index Katello::PuppetModule.index do
          import sublist
        end if !sublist.empty?
      end
    end

    def update_puppet_modules_index
      # for each of the puppet_modules in the repo, unassociate the repo from the module
      puppet_modules = self.puppet_modules.collect{|puppet_module| puppet_module.as_json.merge(puppet_module.index_options)}
      pulp_id = self.pulp_id

      unless puppet_modules.empty?
        Tire.index Katello::PuppetModule.index do
          create :settings => Katello::PuppetModule.index_settings, :mappings => Katello::PuppetModule.index_mapping
        end unless Tire.index(Katello::PuppetModule.index).exists?

        Tire.index Katello::PuppetModule.index do
          import puppet_modules do |documents|
            documents.each do |document|
              if !document["repoids"].nil? && document["repoids"].length > 1
                # if there is more than 1 repo associated w/ the pkg, remove this repo
                document["repoids"].delete(pulp_id)
              end
            end
          end
        end
      end

      # now, for any module that only had this repo asscociated with it, remove the module from the index
      repoids = "repoids:#{pulp_id}"
      Tire::Configuration.client.delete "#{Tire::Configuration.url}/katello_puppet_module/_query?q=#{repoids}"
      Tire.index('katello_puppet_module').refresh
    end

    def errata_count
      results = Katello::Errata.search('', 0, 1, :repoids => [self.pulp_id])
      results.empty? ? 0 : results.total
    end

    def package_count
      results = Katello::Package.search('', 0, 1, :repoids => [self.pulp_id])
      results.empty? ? 0 : results.total
    end

    def puppet_module_count
      results = Katello::PuppetModule.search('', :page_size => 1, :repoids => [self.pulp_id])
      results.empty? ? 0 : results.total
    end

    def index_content
      self.index_packages
      self.index_errata
      self.index_package_groups
      self.index_puppet_modules
      true
    end

    def clear_content_indices
      update_packages_index
      update_errata_index
      update_package_group_index
      update_puppet_modules_index
    end

  end
end
end
