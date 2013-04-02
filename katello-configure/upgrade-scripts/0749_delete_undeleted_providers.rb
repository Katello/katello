#!/usr/bin/ruby
#name: Delete orphan providers
#apply: katello headpin
#run: once
#description:
# RHBZ 885261 and RHBZ 881568 - there were problems when deleting organizations,
# providers were left in a database and foreign keys were referring to wrong IDs.
# This script deletes all orphan providers from Katello database.

ENV["RAILS_ENV"] = 'production'
require "/usr/share/katello/config/boot"
require "/usr/share/katello/config/application"
Rails.application.require_environment!

Provider.all.each do |p|
  unless Organization.unscoped.find_by_id(p.organization_id)
    puts "Deleting provider #{p.id}"
    p.delete
  end
end
