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
  attr_accessor :id, :download_url, :checksum, :license, :group, :filename, :requires,  :provides, :description, :size, :buildhost


  def self.find id
    Glue::Pulp::Package.new(Pulp::Package.find(id))
  end


  def self.index_mapping
    {
      :package => {
        :properties => {
          :name          => { :type=> 'string', :analyzer=>'keyword'}, 
          :nvrea         => { :type=> 'string', :analyzer=>'keyword'},
          :nvrea_sort    => { :type => 'string', :index=> :not_analyzed }
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
        filter :terms, :repository_ids => repoids
      end
      sort { by sort[0], sort[1] }      
     end
     to_ret = []
     search.results.each{|pkg|  
        to_ret << pkg.name if !to_ret.include?(pkg.name)
        break if to_ret.size == number
     } 
     return to_ret
  end

  def self.search query, start, page_size, repoids=nil, not_repoids=nil, sort=[:nvrea_sort, "ASC"]
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
        filter :terms, :repository_ids => repoids
      end
      if not_repoids
        #filter do
        #   not :terms, :repository_ids => not_repoids
        #end 
      end

      sort { by sort[0], sort[1] }
    end
    return search.results
  rescue
    return []
  end

end
