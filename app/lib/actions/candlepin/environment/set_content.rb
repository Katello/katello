module Actions
  module Candlepin
    module Environment
      class SetContent < Candlepin::Abstract
        input_format do
          param :cp_environment_id
          param :content_ids, Array
        end

        def existing_ids
          ::Katello::Resources::Candlepin::Environment.
              find(input[:cp_environment_id])[:environmentContent].map do |content|
            content[:contentId]
          end
        end

        def run
          saved_cp_ids = existing_ids
          add_ids    = input[:content_ids] - saved_cp_ids
          delete_ids = saved_cp_ids - input[:content_ids]
          retries = 2
          (retries + 1).times do
            output[:add_ids] = add_ids
            break if add_ids.empty?
            begin
              output[:add_response] = ::Katello::Resources::Candlepin::Environment.
                add_content(input[:cp_environment_id], add_ids)
              break
            rescue RestClient::InternalServerError
              # HACK
              # Candlepin raises a 500 in case it gets a duplicate content id add to a environment
              # so as pure conjecture we are using this and just guessing if its a dup id.
              # so trying again
              add_ids = input[:content_ids] - existing_ids
            end
          end

          output[:delete_ids]      = delete_ids
          unless delete_ids.empty?
            output[:delete_response] = ::Katello::Resources::Candlepin::Environment.
                delete_content(input[:cp_environment_id], delete_ids)
          end
        end
      end
    end
  end
end
