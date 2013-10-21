require 'util/password'
require 'util/puppet'

class KtSeedData < ActiveRecord::Migration

  def self.up
    Katello::Engine.load_seed
  end

  def self.down
    Katello::Role.find_by_name(Katello::Role::ADMINISTRATOR).try(:update_attributes, {:locked => false})
    Katello::Role.find_by_name(Katello::Role::ADMINISTRATOR).try(:destroy)
    Katello::Role.find_by_name('Read Everything').try(:update_attributes, {:locked => false})
    Katello::Role.find_by_name('Read Everything').try(:destroy)
    ::User.admin.update_attributes(:remote_id => nil)
    # TODO - could not rollback and detroy hidder user or first organization
    # ::User.hidden.first.try(:destroy)
    # first_org_name = (org = Util::Puppet.config_value("org_name")).blank? ? 'ACME_Corporation' : org
    # Katello::Organization.find_by_name(first_org_name).try(:destroy)
  end

end
