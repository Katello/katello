# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

# this is for 0.8.7 (el6) vs 0.9.0+ compatibility
begin
  require 'rake/dsl_definition'
  require 'rake'
  include Rake::DSL
rescue Exception
  require 'rake'
end

task :default => [:spec]

#Src::Application.load_tasks

require 'rubygems'
require 'rake'
require 'fileutils'

ENGINE_DIR = File.expand_path('..', __FILE__)
FOREMAN_DIR = 'test/foreman_app'

namespace :test do
  desc "Download latest foreman devel source and install dependencies"
  task :foreman_prepare do
    foreman_repo = 'https://github.com/theforeman/foreman.git'
    foreman_gemfile = File.join(FOREMAN_DIR, "Gemfile")
    unless File.exists?(foreman_gemfile)
      puts "Foreman source code is not present at #{FOREMAN_DIR}"
      puts "Downloading latest Foreman development branch into #{FOREMAN_DIR}..."
      FileUtils.mkdir_p(FOREMAN_DIR)

      unless system("git clone #{foreman_repo} #{FOREMAN_DIR}")
        puts "Error while getting latest Foreman code from #{foreman_repo} into #{FOREMAN_DIR}"
        fail
      end
    end

    gemfile_content = File.read(foreman_gemfile)
    unless gemfile_content.include?('FOREMAN_GEMFILE')
      puts 'Preparing Gemfile'
      gemfile_content.gsub!('__FILE__', 'FOREMAN_GEMFILE')
      gemfile_content.insert(0, "FOREMAN_GEMFILE = __FILE__ unless defined? FOREMAN_GEMFILE\n")
      File.open(foreman_gemfile, 'w') { |f| f << gemfile_content }
    end

    settings_file = "#{FOREMAN_DIR}/config/settings.yaml"
    unless File.exists?(settings_file)
      puts 'Preparing settings file'
      FileUtils.copy("#{settings_file}.example", settings_file)
      settings_content = File.read(settings_file)
      settings_content.sub!('organizations_enabled: false', 'organizations_enabled: true')
      settings_content << ":puppetgem: true\n"
      File.open(settings_file, 'w') { |f| f << settings_content }
    end

    db_file = "#{FOREMAN_DIR}/config/database.yml"
    unless File.exists?(db_file)
      puts 'Preparing database file'
      FileUtils.copy("#{db_file}.example", db_file)
    end

    ["#{ENGINE_DIR}/.bundle/config", "#{FOREMAN_DIR}/.bundle/config"].each do |bundle_file|
      unless File.exists?(bundle_file)
        FileUtils.mkdir_p(File.dirname(bundle_file))
        puts 'Preparing bundler configuration'
        File.open(bundle_file, 'w') { |f| f << <<FILE }
---
BUNDLE_WITHOUT: console:development:fog:jsonp:libvirt:mysql:mysql2:ovirt:postgresql:vmware
FILE
      end
    end

    local_gemfile = "#{FOREMAN_DIR}/bundler.d/Gemfile.local.rb"
    unless File.exist?(local_gemfile)
      File.open(local_gemfile, 'w') { |f| f << <<GEMFILE }
gem "puppet"
gem "facter"
GEMFILE
    end

    puts 'Installing dependencies...'
    unless system('bundle install')
      fail
    end
  end

  task :db_prepare do
    unless File.exists?(FOREMAN_DIR)
      puts <<MESSAGE
Foreman source code not prepared. Run

  rake test:foreman_prepare

to download foreman source and its dependencies
MESSAGE
      fail
    end

    # once we are Ruby19 only, switch to block variant of cd
    pwd = FileUtils.pwd
    FileUtils.cd(FOREMAN_DIR)
    unless system('rake db:test:prepare RAILS_ENV=test')
      puts "Migrating database first"
      system('rake db:migrate db:schema:dump db:test:prepare RAILS_ENV=test') || fail
    end
    FileUtils.cd(pwd)
  end

  task :set_loadpath do
    %w[lib test].each do |dir|
      $:.unshift(File.expand_path(dir, ENGINE_DIR))
    end
  end

  task :all => [:db_prepare, :set_loadpath] do
    Dir.glob('test/**/*_test.rb') { |f| require f.sub('test/','')  unless f.include? '/foreman_app/' }
  end

end
