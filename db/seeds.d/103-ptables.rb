# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#

::User.current = ::User.anonymous_api_admin

# Partition tables

# Ensure all default partition tables are seeded into the first org and loc
Ptable.where(:default => true, :name => 'Kickstart default').each do |template|
  template.organizations << Organization.first unless template.organizations.include?(Organization.first) || Organization.count.zero?
  if Location.exists? && Location.default_location && !template.locations.include?(Location.default_location)
    template.locations << Location.default_location
  end
end

::User.current = nil
