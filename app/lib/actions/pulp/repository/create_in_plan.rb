module Actions
  module Pulp
    module Repository
      class CreateInPlan < Create
        alias_method :perform_run, :run

        def plan(input)
          plan_self(input)
          pulp_extensions.repository.create_with_importer_and_distributors(input[:pulp_id],
                                                                                      importer,
                                                                                      distributors,
                                                                                      display_name: input[:name])
        rescue => e
          raise error_message(e.http_body) || e
        end

        def error_message(body)
          JSON.parse(body)['error_message']
        rescue JSON::ParserError
          nil
        end

        def run
          self.output = input
        end
      end
    end
  end
end
