module Actions
  module Katello
    module Repository
      class IncrementalImport < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        input_format do
          param :id, Integer
        end

        # @param repo
        # @param import_location location of files to import
        def plan(repo, import_location)
          action_subject(repo)

          rpm_files = Dir.glob(File.join(import_location, "*rpm"))

          json_files = Dir.glob(File.join(import_location, "*json"))
          pulp_units = json_files.map { |json_file| JSON.parse(File.read(json_file)) }
          errata = pulp_units.select { |pulp_unit| erratum? pulp_unit }

          sequence do
            # NB: UploadFiles may time out during plan phase, it copies
            # everything to /tmp. It is better to just have Pulp generate
            # incrementals in the same way it publishes normally, vs optimizing
            # this call. https://pulp.plan.io/issues/1543
            plan_action(Katello::Repository::UploadFiles, repo, rpm_files)
            plan_action(Katello::Repository::UploadErrata, repo, errata)
          end

          plan_self
        end

        def run
          # Assume contents changed. This type of upload does not need the same
          # level of optimization as sync because it is not called frequently.
          output[:contents_changed] = true
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        private

        def erratum?(obj)
          # There is no metadata that says "this json is an erratum" so you
          # have to use this heuristic. Returns true if erratum fields are
          # present, false otherwise
          obj.try(:[], 'unit_key').try(:[], 'id') &&
            obj.try(:[], 'unit_metadata').try(:[], 'type') &&
            obj.try(:[], 'unit_metadata').try(:[], 'issued')
        end
      end
    end
  end
end
