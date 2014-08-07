module Katello
  class SystemHostJoin < ActiveRecord::Base

    belongs_to :host, :class_name => "::Host::Managed", :foreign_key => :host_id
    belongs_to :system, :class_name => "Katello::System", :foreign_key => :system_id
    belongs_to :kt_environment, :class_name => "Katello::KTEnvironment", :foreign_key => :kt_environment_id
    belongs_to :content_view, :class_name => "Katello::ContentView", :foreign_key => :content_view_id

  end
end