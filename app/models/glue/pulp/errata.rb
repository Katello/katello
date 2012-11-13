#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'set'
require 'util/search'
require 'util/package_util'
class Glue::Pulp::Errata

  SECURITY = "security"
  BUGZILLA = "bugfix"
  ENHANCEMENT = "enhancement"

  attr_accessor :id, :title, :description, :version, :release, :type, :status, :updated,  :issued, :from_str, :reboot_suggested, :references, :pkglist, :severity, :repoids

  def initialize(params = {})
    params.each_pair {|k,v| instance_variable_set("@#{k}", v) unless v.nil? }
  end

  def self.errata_by_consumer(repos)
    Resources::Pulp::Consumer.errata_by_consumer(repos)
  end

  def self.find(id)
    erratum_attrs = Resources::Pulp::Errata.find(id)
    Glue::Pulp::Errata.new(erratum_attrs) if not erratum_attrs.nil?
  end

  def self.filter(filter)
    errata = []
    filter_for_repo = filter.slice(:repoid, :environment_id, :product_id)
    filter_for_errata = filter.except(*filter_for_repo.keys)

    repos = repos_for_filter(filter_for_repo)
    repos.each {|repo| errata.concat(Resources::Pulp::Repository.errata(repo.pulp_id, filter_for_errata)) }
    errata
  end

  def self.repos_for_filter(filter)
    if repoid = filter[:repoid]
      return [Repository.find(repoid)]
    elsif environment_id = filter[:environment_id]
      env = KTEnvironment.find(environment_id)
      if product_id = filter[:product_id]
        products = [env.products.find_by_cp_id!(product_id)]
      else
        products = env.products
      end
      return products.map {|p| p.repos(env) }.flatten
    else
      raise "Not enough arguments for finding repos"
    end
  end

  def self.index_settings
    {
        "index" => {
            "analysis" => {
                "filter" => {
                    "ngram_filter"  => {
                        "type"      => "nGram",
                        "min_gram"  => 3,
                        "max_gram"  => 40
                    }
                }.merge(Katello::Search::custom_filters),
                "analyzer" => {
                    "title_analyzer" => {
                        "type"      => "custom",
                        "tokenizer" => "keyword",
                        "filter"    => ["standard", "lowercase", "asciifolding", "ngram_filter"]
                    }
                }.merge(Katello::Search::custom_analyzers)
            }
        }
    }
  end

  def self.index_mapping
    {
      :errata => {
        :properties => {
          :repoids      => { :type => 'string', :index =>:not_analyzed},
          :id_sort      => { :type => 'string', :index => :not_analyzed},
          :id_title     => { :type => 'string', :analyzer =>:title_analyzer},
          :id           => { :type => 'string', :analyzer =>:snowball},
          :product_ids  => { :type => 'integer', :analyzer =>:kt_name_analyzer},
          :severity     => { :type => 'string', :analyzer =>:kt_name_analyzer},
          :type         => { :type => 'string', :analyzer =>:kt_name_analyzer},
          :title        => { :type => 'string', :analyzer => :title_analyzer},
        }
      }
    }
  end

  def self.index
    "#{Katello.config.elastic_index}_errata"
  end

  def index_options
    {
      "_type" => :errata,
      :id_sort => self.id,
      :id_title => self.id + ' : ' + self.title,
      :product_ids => self.product_ids
    }
  end

  def self.search query, start, page_size, filters={}, sort=[:id_sort, "DESC"]
    return [] if !Tire.index(self.index).exists?
    all_rows = query.blank?
    search = Tire::Search::Search.new(self.index)
    search.instance_eval do
      query do
        if all_rows
          all
        else
          string query, {:default_field=>'id_title'}
        end
      end

      if page_size > 0
       size page_size
       from start
      end
      if filters.has_key?(:type)
        filter :term, :type => filters[:type]
      end
      if filters.has_key?(:severity)
        filter :term, :severity => filters[:severity]
      end

      sort { by sort[0], sort[1] } unless !all_rows
    end

    if filters.has_key?(:repoids)
      search_mode = filters[:search_mode] || :all
      repoids = filters[:repoids]
      Katello::PackageUtils.setup_shared_unique_filter(repoids, search_mode, search)
    end

    return search.perform.results
  rescue Tire::Search::SearchRequestFailed => e
    Support.array_with_total
  end

  def self.index_errata errata_ids
    errata = errata_ids.collect{ |errata_id|
      erratum = self.find(errata_id)
      erratum.as_json.merge(erratum.index_options)
    }

    Tire.index Glue::Pulp::Errata.index do
      create :settings => Glue::Pulp::Errata.index_settings, :mappings => Glue::Pulp::Errata.index_mapping
      import errata
    end if !errata.empty?
  end

  def product_ids
    product_ids = []

    self.repoids.each do |repoid|
      # there is a problem, that Pulp in versino <= 0.0.265-1 doesn't remove
      # repo frmo errata when deleting repository. Therefore there might be a
      # situation that repo is not in Pulp anymore, see BZ 790356
      if repo = Repository.where(:pulp_id => repoid)[0]
        product_ids << repo.product.id
      end
    end

    product_ids.uniq
  end

  def included_packages
    packages = []

    self.pkglist.each do |pack_list|
      packages += pack_list['packages'].collect do |err_pack|
        Glue::Pulp::Package.new(err_pack)
      end
    end

    packages
  end

end
