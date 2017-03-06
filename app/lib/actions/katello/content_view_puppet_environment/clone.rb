module Actions
  module Katello
    module ContentViewPuppetEnvironment
      class Clone < Actions::Base
        attr_accessor :new_puppet_environment

        def plan(from_version, options)
          environment = options.fetch(:environment, nil)
          new_version = options.fetch(:new_version, nil)
          puppet_modules_present = options.fetch(:puppet_modules_present, true)
          source = from_version.content_view_puppet_environments.archived.first

          #don't create a cvpe if no puppet modules are present, but reuse it if it is present
          if environment
            clone = find_or_build_puppet_env(from_version, environment, puppet_modules_present)
            return if clone.new_record? && !puppet_modules_present #CVPE is not needed
          else
            clone = find_or_build_puppet_archive(new_version)
          end

          sequence do
            if clone.puppet_environment.nil? && !puppet_modules_present
              plan_action(ContentViewPuppetEnvironment::Destroy, clone)
            else
              clone = setup_puppet_environment_clone(from_version, clone)

              self.new_puppet_environment = clone
              plan_action(Pulp::Repository::CopyPuppetModule,
                          source_pulp_id: source.pulp_id,
                          target_pulp_id: clone.pulp_id,
                          criteria: nil)

              concurrence do
                plan_action(Katello::Repository::MetadataGenerate, clone) if environment
                plan_action(Pulp::ContentViewPuppetEnvironment::IndexContent, id: clone.id)
              end
            end
          end
        end

        private

        def setup_puppet_environment_clone(from_version, clone)
          if clone.new_record?
            plan_action(ContentViewPuppetEnvironment::Create, clone, true)
          else
            clone.content_view_version = from_version
            clone.puppet_environment.try(:save!) #manually save puppet environment in case of error
            clone.save!
            plan_action(ContentViewPuppetEnvironment::Clear, clone)

            unless ::Katello::Repository.needs_distributor_updates([clone], ::Katello::CapsuleContent.new(::SmartProxy.default_capsule)).empty?
              plan_action(Pulp::Repository::Refresh, clone)
            end
          end
          clone
        end

        # The environment clone of the repository is the one
        # visible for the systems in the environment
        def find_or_build_puppet_env(version, environment, puppet_modules_present)
          puppet_env = ::Katello::ContentViewPuppetEnvironment.in_content_view(version.content_view).
              in_environment(environment).readonly(false).first
          puppet_env = version.content_view.build_puppet_env(:environment => environment) unless puppet_env

          if puppet_env.puppet_environment.nil? && puppet_modules_present
            puppet_env.puppet_environment = ::Katello::Foreman.build_puppet_environment(version.content_view.organization,
                                                                                       environment, version.content_view)
          end
          puppet_env
        end

        def find_or_build_puppet_archive(new_version)
          puppet_env = new_version.archive_puppet_environment
          puppet_env = new_version.content_view.build_puppet_env(:version => new_version) unless puppet_env
          puppet_env
        end
      end
    end
  end
end
