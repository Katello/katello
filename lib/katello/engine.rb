module Katello

  class Engine < ::Rails::Engine
    engine_name 'katello'

    initializer "foreman_content.load_app_instance_data" do |app|
      app.config.paths['db/migrate'] += Katello::Engine.paths['db/migrate'].existent
    end

  end

  def table_name_prefix
    'katello_'
  end

  def use_relative_model_naming
    true
  end

  def self.table_name_prefix
    'katello_'
  end

end
