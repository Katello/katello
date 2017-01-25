# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#

if Location.exists? &&
    !Setting[:default_location_subscribed_hosts].present? ||
    !Setting[:default_location_puppet_content].present?
  # Create a new location to be used as the Katello Default.
  default_location = Location.where(:name => ENV['SEED_LOCATION']).first_or_create
  if Setting[:default_location_subscribed_hosts].empty?
    Setting[:default_location_subscribed_hosts] = default_location.title
  end
  if Setting[:default_location_puppet_content].empty?
    Setting[:default_location_puppet_content] = default_location.title
  end
end
