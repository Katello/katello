# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#

if Location.exists? && !Location.default_location
  # Create a new location to be used as the Katello Default.
  Location.create!(:name => "Default Location") do |loc|
    loc.katello_default = true
  end
end
