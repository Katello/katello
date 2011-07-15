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

class Glue::Pulp::Repo
  attr_accessor :id, :groupid, :arch, :name, :feed, :feed_cert, :feed_key, :feed_ca, :clone_ids, :uri_ref

  def initialize(params = {})
    params.each_pair {|k,v| instance_variable_set("@#{k}", v) unless v.nil? }
  end

  SYNC_STATE_FINISHED = "finished"
  SYNC_STATE_ERROR = "error"
  SYNC_STATE_RUNNING = "running"
  SYNC_STATE_NOT_SYNCED = "notsynced"
  SYNC_STATE_WAITING = "waiting"

  TYPE_YUM = "yum"
  TYPE_LOCAL = "local"

  def create
    feed_cert_data = {:ca => self.feed_ca,
        :cert => self.feed_cert,
        :key => self.feed_key
    }
    Pulp::Repository.create({
        :id => self.id,
        :name => self.name,
        :arch => self.arch,
        :feed => self.feed,
        :feed_cert_data => feed_cert_data,
        :groupid => self.groupid
    })
  end

  def destroy
    Pulp::Repository.destroy(repo_id(name))
  end

  def packages
    if @repo_packages.nil?
      self.packages = Pulp::Repository.packages(id)
    end
    @repo_packages
  end

  def packages=attrs
    @repo_packages = attrs.collect do |package|
        Glue::Pulp::Package.new(package)
    end
    @repo_packages
  end

  def errata
    if @repo_errata.nil?
       self.errata = Pulp::Repository.errata(id)
    end
    @repo_errata
  end

  def errata=attrs
    @repo_errata = attrs.collect do |erratum|
        Glue::Pulp::Errata.new(erratum)
    end
    @repo_errata
  end

  def distributions
    if @repo_distributions.nil?
      self.distributions = Pulp::Repository.distributions(id)
    end
    @repo_distributions
  end

  def distributions=attrs
    @repo_distributions = attrs.collect do |dist|
        Glue::Pulp::Distribution.new(dist)
    end
    @repo_distributions
  end

  def has_package? id
    self.packages.each {|pkg|
      return true if pkg.id == id
    }
    return false
  end

  def has_erratum? id
    self.errata.each {|err|
      return true if err.id == id
    }
    return false
  end

  def sync
    Glue::Pulp::Sync.new(Pulp::Repository.sync(id))
  end

  def sync_status
    self._get_most_recent_sync_status()
  end

  def sync_state
    status = self._get_most_recent_sync_status()
    return Repo::SYNC_STATE_NOT_SYNCED if status.nil?
    status.state
  end

  def sync_start
    status = _get_most_recent_sync_status()
    retval = nil
    if status.nil? or status.start_time.nil?
      retval = nil
    else
      retval = status.start_time
      # retval = date.strftime("%H:%M:%S %Y-%m-%d")
    end
    retval
  end

  def cancel_sync
    history = Pulp::Repository.sync_history(@id)
    return if (history.nil? or history.empty?)

    Pulp::Repository.cancel(@id.to_s, history[0][:id])
  end

  def add_packages pkg_id_list
    Pulp::Repository.add_packages self.id,  pkg_id_list
  end

  def add_errata errata_id_list
    Pulp::Repository.add_errata self.id,  errata_id_list
  end

  def sync_finish
    status = _get_most_recent_sync_status()
    retval = nil
    if status.nil? or status.finish_time.nil?
      retval = nil
    else
      retval = status.finish_time
      # retval = date.strftime("%H:%M:%S %Y-%m-%d")
    end
    retval
  end


  def _get_most_recent_sync_status()
    history = Pulp::Repository.sync_history(@id)
    return Glue::Pulp::SyncStatus.new(:state => Glue::Pulp::Repo::SYNC_STATE_NOT_SYNCED) if (history.nil? or history.empty?)
    Glue::Pulp::SyncStatus.new(history[0])
  end

  def synced?
    sync_history = Pulp::Repository.sync_history @id
    !sync_history.nil? && !sync_history.empty? && successful_sync?(sync_history[0])
  end

  def successful_sync?(sync_history_item)
    sync_history_item['state'] == 'finished'
  end

  def promote(to_environment, product)
    cloned = Glue::Pulp::Repo.new
    cloned.id = Glue::Pulp::Repos.clone_repo_id(id, to_environment.name)
    cloned.arch = arch
    cloned.name = name
    cloned.feed = feed
    cloned.groupid = Glue::Pulp::Repos.groupid(product, to_environment)
    Pulp::Repository.clone_repo(self, cloned)
    cloned
  end

  def organization
    Organization.find(groupid[2]["org:".size..-1].to_i)
  end

  def environment
    KPEnvironment.find(groupid[1]["env:".size..-1].to_i)
  end

  def product
    Product.find(groupid[0]["product:".size..-1].to_i)
  end

  def self.find(id)
    Glue::Pulp::Repo.new(Pulp::Repository.find(id))
  end

  # Convert array of Repo objects to Ruby Hash in the form of repo.id => repo_object for fast searches.
  #
  # @param array_to_hash array of Repo objects
  # @returns Hash structure
  def self.array_to_hash(array_of_repos)
    Hash[*array_of_repos.collect { |r|
      [r.id, r]
    }.flatten]
  end

end
