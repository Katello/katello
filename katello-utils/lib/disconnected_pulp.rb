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
# Manifest representation in Ruby
#

require 'runcible'

# This class provides business logic for katello-disconnected CLI tool.
# Individual methods represent cli actions (verbs). This class communicates
# with Pulp using Runcible rubygem, therefore Runcible must be configured.
#
class DisconnectedPulp
  attr_accessor :active_manifest, :manifest

  def initialize active_manifest, options, log
    @active_manifest = active_manifest
    @manifest = active_manifest.manifest
    @options = options
    @log = log
  end

  def LOG; @log; end

  def dry_run(&block)
    block.call unless @options[:dry_run]
  end

  def list disabled = false
    if disabled
      puts manifest.repositories.values.collect {|r| r.repoid }.sort
    else
      puts manifest.enabled_repositories
    end
  end

  def clean
    Runcible::Resources::Repository.retrieve_all.each do |repo|
      LOG.verbose _("Removing repo %s") % repo['id']
      dry_run do
        Runcible::Resources::Repository.delete repo['id']
      end
    end
  end

  def enable value, repoids = nil, all = nil
    if repoids
      repoids = repoids.split(/,\s*/).collect(&:strip)
    else
      if all
        repoids = manifest.repositories.keys
      else
        LOG.error _('You need to provide some repoids')
        return
      end
    end
    repoids.each do |repoid|
      LOG.verbose _("Setting enabled flag to %{value} for %{repoid}") % {:value => value, :repoid => repoid}
      manifest.enable_repository repoid, value
    end
    active_manifest.save_repo_conf
  end

  def configure remove_disabled = false
    active_repos = manifest.repositories
    mfrepos = manifest.enabled_repositories
    purepos = Runcible::Resources::Repository.retrieve_all.collect { |m| m['id'] }
    repos_to_be_added = mfrepos - purepos
    repos_to_be_removed = purepos - mfrepos
    LOG.debug _("Enabled repos: %s") % mfrepos.inspect
    LOG.debug _("Pulp repos: %s") % purepos.inspect
    LOG.debug _("To be added: %s") % repos_to_be_added.inspect
    # remove extra repos
    if remove_disabled and repos_to_be_removed.size > 0
      LOG.debug _("To be removed: %s") % repos_to_be_removed.inspect
      repos_to_be_removed.each do |repoid|
        LOG.verbose _("Removing repo %s") % repoid
        dry_run do
          Runcible::Resources::Repository.delete repoid
        end
      end
    end
    # add new repos
    repos_to_be_added.each do |repoid|
      LOG.verbose _("Creating repo %s") % repoid
      dry_run do
        repo = active_repos[repoid]
        yum_importer = Runcible::Extensions::YumImporter.new
        yum_importer.feed_url = repo.url
        yum_importer.ssl_ca_cert = manifest.read_cdn_ca
        yum_importer.ssl_client_cert = repo.cert
        yum_importer.ssl_client_key = repo.key
        Runcible::Extensions::Repository.create_with_importer(repoid, yum_importer)
      end
    end
  end

  def synchronize repoids = nil
    if repoids
      repoids = repoids.split(/,\s*/).collect(&:strip)
    else
      repoids = Runcible::Resources::Repository.retrieve_all.collect{|r| r['id']}
    end
    repoids.each do |repoid|
      begin
        LOG.verbose _("Synchronizing repo %s") % repoid
        dry_run do
          Runcible::Resources::Repository.sync repoid
        end
      rescue RestClient::ResourceNotFound => e
        LOG.error _("Repo %s not found, skipping") % repoid
      end
    end
  end

  def watch delay_time = nil, repoids = nil, once = nil
    if delay_time.nil?
      delay_time = 10
    else
      delay_time = delay_time.to_i rescue 1
      delay_time = 1 if delay_time < 1
    end
    if repoids
      repoids = repoids.split(/,\s*/).collect(&:strip)
    else
      repoids = Runcible::Resources::Repository.retrieve_all.collect{|r| r['id']}
    end
    puts _('Watching sync... (this may be safely interrupted with Ctrl+C)')
    finished_repoids = {}
    running = true
    while running
      statuses = {}
      begin
        repoids.each do |repoid|
          begin
            # skip if this repo was already finished
            next if finished_repoids[repoid]
            status = Runcible::Extensions::Repository.sync_status repoid
            state = status[0]['state'] || 'unknown' rescue 'unknown'
            exception = status[0]['exception'] || '' rescue ''
            statuses[state] = [] if statuses[state].nil?
            statuses[state] << [repoid, exception] if not repoid.nil?
            # remove finished repos
            finished_repoids[repoid] = true if state == 'finished' or state == 'unknown'
          rescue RestClient::ResourceNotFound => e
            LOG.fatal _("Repo %s not found") % repoid
          rescue SignalException => e
            raise e
          rescue Exception => e
            LOG.error _("Error while getting status for %{repoid}: %{msg}") % {:repoid => repoid, :msg => e.message}
          end
        end
        statuses.keys.sort.each do |state|
          puts "#{state}:"
          statuses[state].each do |pair|
            puts "#{pair[0]} #{pair[1]}"
          end
        end
        puts "\n"
        running = false if once or statuses.count == 0
        sleep delay_time
      rescue SignalException => e
        puts "\n" + _('Watching stopped, the following repos have finished:')
        finished_repoids.keys.sort.each { |repoid| puts repoid }
        running = false
      end
    end
    puts _('Watching finished')
  end

  def export target_basedir = nil, repoids = nil, overwrite = false, onlycreate = false, onlyexport = false
    LOG.fatal _('Please provide target directory, see --help') if target_basedir.nil?
    overwrite = false if overwrite.nil?
    onlycreate = false if onlycreate.nil?

    active_repos = manifest.repositories
    if repoids
      repoids = repoids.split(/,\s*/).collect(&:strip)
    else
      repoids = Runcible::Resources::Repository.retrieve_all.collect{|r| r['id']}
    end
    # create directory structure
    repoids.each do |repoid|
      repo = active_repos[repoid]
      target_dir = File.join(target_basedir, repo.path)
      if not onlyexport
        LOG.verbose "Creating #{target_dir}"
        FileUtils.mkdir_p target_dir
      end
    end
    # create listing files
    Find.find(target_basedir) do |path|
      if FileTest.directory? path
        File.open(File.join(path, 'listing'), 'w') do |file|
          Dir[File.join(path, '*/')].each do |dir|
            file.write(File.basename(dir) + "\n")
          end
        end
      end
    end
    # change owner to apache
    begin
      FileUtils.chown_R 'apache', 'apache', target_basedir
    rescue Errno::EPERM => e
      LOG.error _("Cannot chown to 'apache' - %s") % e.message
    end
    # initiate export
    repoids.each do |repoid|
      repo = active_repos[repoid]
      target_dir = File.join(target_basedir, repo.path)
      begin
        if not onlycreate
          LOG.verbose _("Exporting repo %s") % repoid
          dry_run do
            Runcible::Resources::Repository.export_NOT_IMPLEMENTED repoid, target_dir, overwrite
          end
        end
      rescue RestClient::ResourceNotFound => e
        LOG.error _("Repo %s not found, skipping") % repoid
      end
    end
  end
end
