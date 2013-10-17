class KtSeedData < ActiveRecord::Migration

  def self.up
    Katello::Engine.load_seed
  end

  def self.down
    Katello::Role.find_by_name(Katello::Role::ADMINISTRATOR).try(:update_attributes, {:locked => false})
    Katello::Role.find_by_name(Katello::Role::ADMINISTRATOR).try(:destroy)
    Katello::Role.find_by_name('Read Everything').try(:update_attributes, {:locked => false})
    Katello::Role.find_by_name('Read Everything').try(:destroy)
    ::User.admin.update_attributes(:username => nil, :email => nil, :remote_id => nil)
#    ::User.hidden.first.try(:destroy)
#    first_org_name = (org = Util::Puppet.config_value("org_name")).blank? ? 'ACME_Corporation' : org
#    Katello::Organization.find_by_name(first_org_name).try(:destroy)
    Katello::Provider.find_by_name('Custom Provider 1').try(:destroy)
    Katello::Provider.find_by_name('Red Hat').try(:destroy)
  end

end
