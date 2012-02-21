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

require_dependency "resources/pulp"
class Glue::Pulp::Package < Glue::Pulp::SimplePackage
  attr_accessor :id, :download_url, :checksum, :license, :group, :filename, :requires,  :provides, :description, :size, :buildhost, :repoids


  def self.find id
    package_attrs = Pulp::Package.find(id)
    Glue::Pulp::Package.new(package_attrs) if not package_attrs.nil?
  end

  def self.index_settings
    {
        "index" => {
            "analysis" => {
                "filter" => {
                    "ngram_filter"  => {
                        "type"      => "edgeNGram",
                        "side"      => "front",
                        "min_gram"  => 1,
                        "max_gram"  => 10
                    }
                },
                "analyzer" => {
                    "name_analyzer" => {
                        "type"      => "custom",
                        "tokenizer" => "keyword",
                        "filter"    => ["standard", "lowercase", "asciifolding", "ngram_filter"]
                    }
                }
            }
        }
    }
  end

  def self.index_mapping
    {
      :package => {
        :properties => {
          :name          => { :type=> 'string', :analyzer=>'name_analyzer'},
          :nvrea         => { :type=> 'string', :analyzer=>'keyword'},
          :nvrea_sort    => { :type => 'string', :index=> :not_analyzed },
          :repoids       => { :type=> 'string', :analyzer=>'keyword'}
        }
      }
    }
  end

  def self.index
    "#{AppConfig.elastic_index}_package"
  end

  def index_options
    {
      "_type" => :package,
      "nvrea_sort" => nvrea.downcase,
      "nvrea" => nvrea
    }
  end

  def self.name_search query, repoids=nil, number=15, sort=[:nvrea_sort, "ASC"]
    return [] if !Tire.index(self.index).exists?
     start = 0
     query = "name:#{query}"
     search = Tire.search self.index do
      fields [:name]
      query do
        string query
      end

      if repoids
        filter :terms, :repoids => repoids
      end
     end
     to_ret = []
     search.results.each{|pkg|
        to_ret << pkg.name if !to_ret.include?(pkg.name)
        break if to_ret.size == number
     }
     return to_ret
  end

  def self.search query, start, page_size, repoids=nil, sort=[:nvrea_sort, "ASC"]
    return [] if !Tire.index(self.index).exists?
    query_down = query.downcase
    query = "name:#{query}" if AppConfig.simple_search_tokens.any?{|s| !query_down.match(s)}
    search = Tire.search self.index do
      query do
        string query
      end

      if page_size > 0
       size page_size
       from start
      end
      if repoids
        filter :terms, :repoids => repoids
      end

      sort { by sort[0], sort[1] }
    end
    return search.results
  rescue
    return []
  end

  def self.index_packages pkg_ids
    pkgs = pkg_ids.collect{ |pkg_id|
      pkg = self.find(pkg_id)
      pkg.as_json.merge(pkg.index_options)
    }
    Tire.index Glue::Pulp::Package.index do
      create :settings => Glue::Pulp::Package.index_settings, :mappings => Glue::Pulp::Package.index_mapping
      import pkgs
    end if !pkgs.empty?
  end

end
