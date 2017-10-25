module Katello
  module Concerns
    module EnvironmentExtensions
      extend ActiveSupport::Concern

      included do
        has_one :content_view_puppet_environment, :class_name => "Katello::ContentViewPuppetEnvironment",
                                                  :foreign_key => :puppet_environment_id,
                                                  :dependent => :nullify, :inverse_of => :puppet_environment

        has_one :content_view, :class_name => "Katello::ContentView", :through => :content_view_puppet_environment
        has_one :lifecycle_environment, :class_name => "Katello::KTEnvironment", :through => :content_view_puppet_environment, :source => :environment

        scoped_search :relation => :content_view, :on => :name, :rename => :content_view, :complete_value => true
        scoped_search :relation => :lifecycle_environment, :on => :name, :rename => :lifecycle_environment, :complete_value => true
      end

      def content_view
        self.content_view_puppet_environment.try(:content_view)
      end

      def lifecycle_environment
        self.content_view_puppet_environment.try(:environment)
      end

      def destroy!
        unless destroy
          fail self.errors.full_messages.join('; ')
        end
      end

      module ClassMethods
        def find_by_katello_id(org, env, content_view)
          katello_id = Environment.construct_katello_id(org, env, content_view)
          Environment.where(:katello_id => katello_id).first
        end

        def build_by_katello_id(org, env, content_view)
          env_name = Environment.construct_name(org, env, content_view)
          katello_id = Environment.construct_katello_id(org, env, content_view)
          default_location_id = ::Location.default_puppet_content_location!.id
          environment = Environment.new(:name => env_name,
                                        :organization_ids => [org.id],
                                        :location_ids => [default_location_id])
          environment.katello_id = katello_id
          environment
        end

        def find_or_build_by_katello_id(org, env, content_view)
          Environment.find_by_katello_id(org, env, content_view) ||
              Environment.build_by_katello_id(org, env, content_view)
        end

        def construct_katello_id(org, env, content_view)
          fail ArgumentError, "org has to be specified" if org.nil?
          fail ArgumentError, "env has to be specified" if env.nil?
          [org.label, env.label, content_view.label].reject(&:blank?).join('/')
        end

        # content_view_id provides the uniqueness of the name
        def construct_name(org, env, content_view)
          name = ["KT",
                  org.try(:label),
                  env.try(:label),
                  content_view.try(:label),
                  content_view.try(:id)
                 ].reject(&:blank?).join('_')

          return name.tr('-', '_')
        end
      end
    end
  end
end
