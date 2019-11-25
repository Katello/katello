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
          generated_config.delete('proxy_host')
          generated_config.delete('proxy_username')
          generated_config.delete('proxy_password')
          generated_config.delete('proxy_port')
          capsule_config.delete('proxy_host')
          capsule_config.delete('proxy_username')
          capsule_config.delete('proxy_password')
          capsule_config.delete('proxy_port')
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
