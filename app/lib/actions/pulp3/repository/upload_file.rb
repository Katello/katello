module Actions
  module Pulp3
    module Repository
      class UploadFile < Pulp3::AbstractAsyncTask
        def plan(repository, smart_proxy, file)
          plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id, :file => file)
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          repo_backend_service = repo.backend_service(smart_proxy)
          upload_class = repo_backend_service.core_api.upload_class
          uploads_api = repo_backend_service.core_api.uploads_api
          offset = 0
          response = nil
          File.open(input[:file], "rb") do |file|
            total_size = File.size(file)
            upload_href = uploads_api.create(upload_class.new(size: total_size)).pulp_href
            sha256 = Digest::SHA256.hexdigest(File.read(file))
            until file.eof?
              chunk = file.read(upload_chunk_size)
              begin
                filechunk = Tempfile.new('filechunk', :encoding => 'ascii-8bit')
                filechunk.write(chunk)
                filechunk.flush
                actual_chunk_size = File.size(filechunk)
                response = uploads_api.update(upload_href, content_range(offset, offset + actual_chunk_size - 1, total_size), filechunk)
                offset += actual_chunk_size - 1
              ensure
                filechunk.close
                filechunk.unlink
              end
            end

            if response
              upload_href = response.pulp_href
              output[:pulp_tasks] = [uploads_api.commit(upload_href, sha256: sha256)]
            end
          end
        end

        def external_task=(tasks)
          super
        end

        def finalize
          check_error_details
        end

        def check_error_details
          output[:pulp_tasks].each do |pulp_task|
            error_details = pulp_task.try(:[], "error")
            if error_details && !error_details.nil?
              fail _("An error occurred during the sync \n%{error_message}") % {:error_message => error_details}
            end
          end
        end

        private

        def upload_chunk_size
          SETTINGS[:katello][:pulp][:upload_chunk_size]
        end

        def checksum(file)
          Digest::SHA256.hexdigest(File.read(file))
        end

        def content_range(start, finish, total)
          finish = finish > total ? total : finish
          "bytes #{start}-#{finish}/#{total}"
        end
      end
    end
  end
end
