# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# !!! PLEASE KEEP THIS SCRIPT IDEMPOTENT !!!
#

::User.current = ::User.anonymous_api_admin

# Provisioning Templates

kinds = [:provision, :finish, :user_data].inject({}) do |hash, kind|
  hash[kind] = TemplateKind.find_by(:name => kind)
  hash
end

templates = [{:name => "Katello Kickstart Default",           :source => "kickstart-katello.erb",      :template_kind => kinds[:provision]},
             {:name => "Katello Kickstart Default User Data", :source => "userdata-katello.erb",       :template_kind => kinds[:user_data]},
             {:name => "Katello Kickstart Default Finish",    :source => "finish-katello.erb",         :template_kind => kinds[:finish]},
             {:name => "subscription_manager_registration",   :source => "snippets/_subscription_manager_registration.erb", :snippet => true},
             {:name => "Katello Atomic Kickstart Default",    :source => "kickstart-katello-atomic.erb", :template_kind => kinds[:provision]}]

templates.each do |template|
  template[:template] = File.read(File.join(Katello::Engine.root, "app/views/foreman/unattended", template.delete(:source)))
  ProvisioningTemplate.where(:name => template["name"]).first_or_create do |pt|
    pt.vendor = "Katello"
    pt.default = true
    pt.locked = true
    pt.name = template[:name]
    pt.template = template[:template]
    pt.template_kind = template[:template_kind] if template[:template_kind]
    pt.snippet = template[:snippet] if template[:snippet]
  end
  ProvisioningTemplate.find_by(name: template[:name]).update_attributes!(:template => template[:template])
end

# Ensure all default templates are seeded into the first org and loc
ProvisioningTemplate.where(:default => true).each do |template|
  template.organizations << Organization.first unless template.organizations.include?(Organization.first) || Organization.count.zero?
  if Location.exists? && !template.location_ids.include?(Location.default_location_ids)
    template.location_ids << Location.default_location_ids
  end
end

::User.current = nil
