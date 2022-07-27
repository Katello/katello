module Katello
  module Pulp3
    module ServiceCommon
      def create_remote
        response = nil
        if remote_options[:url]&.start_with?('uln')
          remote_file_data = api.class.remote_uln_class.new(remote_options)
        else
          remote_file_data = api.remote_class.new(remote_options)
        end
        reformat_api_exception do
          if remote_options[:url]&.start_with?('uln')
            response = api.remotes_uln_api.create(remote_file_data)
          else
            response = api.remotes_api.create(remote_file_data)
          end
        end
        response
      end

      def test_remote_name
        "test_remote_#{SecureRandom.uuid}"
      end

      # When updating a repository, we need to update the remote, but this is
      # an async task.  If some validation occurs, we won't know about it until
      # the task runs.  Errors during a repository update task are very difficult to
      # handle once the task is in its run phase, so this creates a test remote
      # with a random name in order to validate the remote's configuration
      def create_test_remote
        test_remote_options = remote_options
        test_remote_options[:name] = test_remote_name
        if remote_options[:url]&.start_with?('uln')
          remote_file_data = api.class.remote_uln_class.new(test_remote_options)
        else
          remote_file_data = api.remote_class.new(test_remote_options)
        end

        reformat_api_exception do
          if remote_options[:url]&.start_with?('uln')
            response = api.remotes_uln_api.create(remote_file_data)
          else
            response = api.remotes_api.create(remote_file_data)
          end
          #delete is async, but if its not properly deleted, orphan cleanup will take care of it later
          delete_remote(href: response.pulp_href)
        end
      end

      def ignore_404_exception(*)
        yield
      rescue api.api_exception_class => e
        raise e unless e.code == 404
        nil
      end

      def reformat_api_exception
        yield
      rescue api.client_module::ApiError => exception
        body = JSON.parse(exception.response_body) rescue body
        body = body.values.join(',') if body.respond_to?(:values)
        raise ::Katello::Errors::Pulp3Error, body
      end
    end
  end
end
