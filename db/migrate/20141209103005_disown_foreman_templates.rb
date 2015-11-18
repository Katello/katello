class DisownForemanTemplates < ActiveRecord::Migration
  class FakeConfigTemplate < ActiveRecord::Base
    if ActiveRecord::Base.connection.table_exists?('config_templates')
      self.table_name = 'config_templates'
    else
      self.table_name = 'templates'
    end
  end

  def up
    update_templates_attributes :locked => false, :vendor => nil
  end

  def down
    update_templates_attributes :locked => true, :vendor => 'Katello'
  end

  private

  def update_templates_attributes(attribute_hash)
    templates = ["puppet.conf", "freeipa_register", "Kickstart default iPXE", "Kickstart default PXELinux", "PXELinux global default"]

    templates.each do |template|
      if (template = FakeConfigTemplate.find_by_name(template))
        template.update_attributes(attribute_hash)
      end
    end
  end
end
