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
          output[:add_ids] = input[:content_ids] - saved_cp_ids
          output[:delete_ids] = saved_cp_ids - input[:content_ids]
          max_retries = 4
          retries = 0
          until output[:add_ids].empty?
            begin
              output[:add_response] = ::Katello::Resources::Candlepin::Environment.
                add_content(input[:cp_environment_id], output[:add_ids])
              break
            rescue RestClient::Conflict => e
              retries += 1
              raise e if retries == max_retries
              # Candlepin raises a 409 in case it gets a duplicate content id add to an environment
              # Since its a dup id refresh the existing ids list (which hopefully will not have the duplicate content)
              # and try again.
              output[:add_ids] = input[:content_ids] - existing_ids
            end
          end

          retries = 0
          until output[:delete_ids].empty?
            begin
              output[:delete_response] = ::Katello::Resources::Candlepin::Environment.
                  delete_content(input[:cp_environment_id], output[:delete_ids])
              break
            rescue RestClient::ResourceNotFound => e
              retries += 1
              raise e if retries == max_retries
              # Candlepin raises a 404 in case a content id is not found in this environment
              # If thats the case lets just refresh the existing ids list (which hopefully will not have the 404'd content)
              # and try again.
              output[:delete_ids] = existing_ids - input[:content_ids]
            end
          end
        end
      end
    end
  end
end
