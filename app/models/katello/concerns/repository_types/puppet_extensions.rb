module Katello
  module Concerns
    module RepositoryTypes
      module PuppetExtensions
        extend ActiveSupport::Concern
        PUPPET_TYPE = 'puppet'
        included do
          has_many :repository_puppet_modules, :class_name => "Katello::RepositoryPuppetModule", :dependent => :destroy
          has_many :puppet_modules, :through => :repository_puppet_modules

          scope :puppet_type, -> { where(:content_type => PUPPET_TYPE) }
          scope :non_puppet, -> { where("content_type != ?", PUPPET_TYPE) }
        end

        def puppet?
          content_type == PUPPET_TYPE
        end

        def name_conflicts
          if puppet?
            modules = PuppetModule.search("*", :repoids => self.pulp_id,
                                               :fields => [:name],
                                               :page_size => self.puppet_modules.count)

            modules.map(&:name).group_by(&:to_s).select { |_, v| v.size > 1 }.keys
          else
            []
          end
        end
      end
    end
  end
end
