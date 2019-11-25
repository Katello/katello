module Katello
  module Pulp
    module ImporterComparison
      def importer_matches?(generated_importer, capsule_importer)
        if capsule_importer.try(:[], 'importer_type_id') != generated_importer.id
          return false
        end

        if generated_importer.config['proxy_host'] == ""
          generated_importer.config.delete('proxy_host')
          generated_importer.config.delete('proxy_username')
          generated_importer.config.delete('proxy_password')
          generated_importer.config.delete('proxy_port')
          capsule_importer['config'].delete('proxy_host')
          capsule_importer['config'].delete('proxy_username')
          capsule_importer['config'].delete('proxy_port')
          capsule_importer['config'].delete('proxy_password')
        end
        if generated_importer.config['proxy_password'] == "" && capsule_importer['config']['proxy_password'] == "*****"
          generated_importer.config.delete('proxy_password')
          capsule_importer['config'].delete('proxy_password')
        end
        generated_importer.config.compact == capsule_importer['config'].compact
      end
    end
  end
end
