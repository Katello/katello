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
require 'set'

class Glue::Pulp::Errata

  SECURITY = "security"
  BUGZILLA = "bugfix"
  ENHANCEMENT = "enhancement"

  attr_accessor :id, :title, :description, :version, :release, :type, :status, :updated,  :issued, :from_str, :reboot_suggested, :references, :pkglist, :severity, :repoids

  def initialize(params = {})
    params.each_pair {|k,v| instance_variable_set("@#{k}", v) unless v.nil? }
  end

  def self.errata_by_consumer(repos)
    Pulp::Consumer.errata_by_consumer(repos)
  end

  def self.find(id)
    Glue::Pulp::Errata.new(Pulp::Errata.find(id))
  end

  def self.filter(filter)
    errata = []
    filter_for_repo = filter.slice(:repoid, :environment_id, :product_id)
    filter_for_errata = filter.except(*filter_for_repo.keys)

    repos = repos_for_filter(filter_for_repo)
    repos.each {|repo| errata.concat(Pulp::Repository.errata(repo.pulp_id, filter_for_errata)) }
    errata
  end

  def self.repos_for_filter(filter)
    if repoid = filter[:repoid]
      return [Repository.find(repoid)]
    elsif environment_id = filter[:environment_id]
      env = KTEnvironment.find(environment_id)
      if product_id = filter[:product_id]
        products = [::Product.find_by_cp_id!(product_id)]
      else
        products = env.products
      end
      return products.map {|p| p.repos(env) }.flatten
    else
      raise "Not enough arguments for finding repos"
    end
  end

  def self.index_mapping
    {
      :package => {
        :properties => {
          :title_sort    => { :type => 'string', :index=> :not_analyzed }
        }
      }
    }
  end

  def self.index
    "#{AppConfig.elastic_index}_errata"
  end

  def index_options
    {
      "_type" => :errata
    }
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
