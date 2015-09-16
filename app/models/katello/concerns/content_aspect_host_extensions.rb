module Katello
  module Concerns
    module ContentAspectHostExtensions
      extend ActiveSupport::Concern

      included do
        has_one :content_aspect, :class_name => '::Katello::Host::ContentAspect', :foreign_key => :host_id, :inverse_of => :host, :dependent =>  :destroy

        #associations for simpler scoped searches
        has_one :content_view, :through => :content_aspect
        has_one :lifecycle_environment, :through => :content_aspect
        scoped_search :in => :content_view, :on => :name, :complete_value => true, :rename => :content_view
        scoped_search :in => :lifecycle_environment, :on => :name, :complete_value => true, :rename => :lifecycle_environment

        accepts_nested_attributes_for :content_aspect, :reject_if => proc { |attributes| attributes['content_view_id'].blank? && attributes['lifecycle_environment_id'].blank? }
      end
    end
  end
end

class ::Host::Managed::Jail < Safemode::Jail
  allow :content_view, :lifecycle_environment
end
