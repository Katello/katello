# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#

def format_errors(model = nil)
  return '(nil found)' if model.nil?
  model.errors.full_messages.join(';')
end

::User.current = ::User.anonymous_api_admin

# Proxy features
feature = Feature.find_or_create_by_name('Pulp')
if feature.nil? || feature.errors.any?
  fail "Unable to create proxy feature: #{format_errors feature}"
end

["Pulp", "Pulp Node"].each do |input|
  f = Feature.find_or_create_by_name(input)
  fail "Unable to create proxy feature: #{format_errors f}" if f.nil? || f.errors.any?
end

::User.current = nil
