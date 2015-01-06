class ContentViewPuppetEnvironmentId < ActiveRecord::Migration
  class ::Environment < ActiveRecord::Base
    def self.find_by_katello_id(org, env, content_view)
      katello_id = Environment.construct_katello_id(org, env, content_view)
      Environment.where(:katello_id => katello_id).first
    end

    def construct_katello_id(org, env, content_view)
      fail ArgumentError, "org has to be specified" if org.nil?
      fail ArgumentError, "env has to be specified" if env.nil?
      [org.label, env.label, content_view.label].reject(&:blank?).join('/')
    end
  end

  class ::Katello::ContentViewPuppetEnvironment < ::Katello::Model
    belongs_to :environment, :class_name => "Katello::KTEnvironment",
                             :inverse_of => :content_view_puppet_environments
    belongs_to :content_view_version, :class_name => "Katello::ContentViewVersion",
                                      :inverse_of => :content_view_puppet_environments

    def content_view
      self.content_view_version.content_view
    end
  end

  def up
    add_column :katello_content_view_puppet_environments, :puppet_environment_id, :integer, :null => true

    Katello::ContentViewPuppetEnvironment.all.each do |cvpe|
      if cvpe.environment
        cvpe.puppet_environment_id = ::Environment.find_by_katello_id(cvpe.content_view.organization,
                                                                    cvpe.environment, cvpe.content_view).id
        cvpe.save!
      end
    end

    add_foreign_key "katello_content_view_puppet_environments", "environments", :name => "katello_cvpe_pe_id", :column => 'puppet_environment_id'
  end

  def down
    remove_foreign_key "katello_content_view_puppet_environments", :name => "katello_cvpe_pe_id"
    remove_column :katello_content_view_puppet_environments, :puppet_environment_id
  end
end
