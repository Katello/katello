module Actions
  module Candlepin
    module Environment
      class SetContent < Candlepin::Abstract
        def plan(content_view, environment, content_view_environment, new_content_id = nil)
          plan_self(:content_view_id => content_view.id,
                    :environment_id => environment.id,
                    :cp_environment_id => content_view_environment.cp_id,
                    :new_content_id => new_content_id)
        end

        def finalize # rubocop:disable Metrics/AbcSize
          content_view = ::Katello::ContentView.find(input[:content_view_id])
          environment = ::Katello::KTEnvironment.find(input[:environment_id])
          content_ids = content_view.repos(environment).map(&:content_id).uniq.compact
          # in case we create new custom repository that doesn't have the
          # content_id set yet in the plan phase, we allow to pass it as
          # additional argument
          content_ids << input[:new_content_id] if input[:new_content_id] && !content_ids.include?(input[:new_content_id])
          saved_cp_ids = existing_ids
          output[:add_ids] = content_ids - saved_cp_ids
          output[:delete_ids] = saved_cp_ids - content_ids
          max_retries = 4
          retries = 0
          until output[:add_ids].empty?
            begin
              output[:add_response] = ::Katello::Resources::Candlepin::Environment.add_content(input[:cp_environment_id], output[:add_ids])
              break
            rescue RestClient::Conflict => e
              raise e if ((retries += 1) == max_retries)
              # Candlepin raises a 409 in case it gets a duplicate content id add to an environment
              # Since its a dup id refresh the existing ids list (which hopefully will not have the duplicate content)
              # and try again.
              output[:add_ids] = content_ids - existing_ids
            end
          end
          retries = 0
          until output[:delete_ids].empty?
            begin
              output[:delete_response] = ::Katello::Resources::Candlepin::Environment.delete_content(input[:cp_environment_id], output[:delete_ids])
              break
            rescue RestClient::ResourceNotFound => e
              if ((retries += 1) == max_retries)
                Rails.logger.warn("Skipping deleting content with ID #{e} because it was not found")
              end
              # Candlepin raises a 404 in case a content id is not found in this environment
              # If thats the case lets just refresh the existing ids list (which hopefully will not have the 404'd content)
              # and try again.
              output[:delete_ids] = existing_ids - content_ids
            end
          end
        end

        def existing_ids
          ::Katello::Resources::Candlepin::Environment.
              find(input[:cp_environment_id])[:environmentContent].map do |content|
            if content.key?('contentId')
              # Supports Candlepin 4.2.11 and up
              content['contentId']
            else
              # Supports Candlepin versions below 4.2.11
              content[:content][:id]
            end
          end
        end
      end
    end
  end
end
