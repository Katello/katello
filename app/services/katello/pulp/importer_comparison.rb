module Katello
  module Pulp
    module ImporterComparison
      def importer_matches?(generated_importer, capsule_importer)
        if capsule_importer.try(:[], 'importer_type_id') != generated_importer.id
          return false
        end

        generated_config = generated_importer.config
        capsule_config = capsule_importer['config']
        if generated_config['proxy_host'] == ""
          proxy_keys = %w(proxy_host proxy_username proxy_password)
          proxy_keys.each do |key|
            generated_config.delete(key)
            capsule_config.delete(key)
          end
        end

        if generated_config['proxy_password'] == "" && capsule_config['proxy_password'] == "*****"
          generated_config.delete('proxy_password')
          capsule_config.delete('proxy_password')
        end

        generated_config.compact == capsule_config.compact
      end
    end
  end
end
